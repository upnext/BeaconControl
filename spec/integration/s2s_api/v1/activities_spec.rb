###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Activities', type: :request, s2s: true do
  let(:application) { FactoryGirl.create(:application, account: admin.account) }
  let!(:url_activity) { FactoryGirl.create(:url_activity, application: application) }
  let!(:coupon_activity) { FactoryGirl.create(:coupon_activity, application: application) }
  let(:beacon) { FactoryGirl.create(:beacon) }
  let(:activity_params) {
    {
      scheme: 'url',
      name: 'Activity name',
      url: 'http://example.com',
      trigger_attributes: { type: 'BeaconTrigger', beacon_ids: [beacon.id] }
    }
  }
  let(:image) { Rack::Test::UploadedFile.new(fixture_file_path('image.jpg'), 'image/jpg') }

  describe '#index' do
    let(:json) { json_response[:activities] }
    let(:activities_ids) { json.map{|a| a[:id]} }

    it 'returns list of activities' do
      get "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(2)

      expect(activities_ids).to match_array([url_activity.id, coupon_activity.id])
      expect(json.detect{|a| a[:scheme]=='url'}).to eq(S2sApi::V1::ActivitySerializer.new(url_activity).as_json(root: false))

      [:id, :name, :payload, :scheme, :trigger].each do |key|
        expect(json.first).to have_key(key)
      end
    end

    it 'includes trigger' do
      get "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token

      as_json = S2sApi::V1::TriggerSerializer.new(url_activity.trigger).as_json(root: false)
      expect(json.first[:trigger]).to eq(as_json)
    end

    it 'includes coupon' do
      get "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token

      expect(json.detect{|a| a[:scheme]=='url'}[:coupon]).to eq(nil)

      as_json = S2sApi::V1::CouponSerializer.new(coupon_activity.coupon).as_json(root: false)
      coupon_json = json.detect{|a| a[:scheme]=='coupon'}[:coupon]
      expect(coupon_json).to eq(as_json)

      [:id, :name, :template, :title, :description, :image, :logo].each do |key|
        expect(coupon_json).to have_key(key)
      end
    end

    it 'scopes list of activities for application' do
      other_application = FactoryGirl.create(:application)
      other_activity = FactoryGirl.create(:url_activity, application: other_application)

      get "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token

      expect(json.size).to eq(2)
      expect(Activity.count).to eq(3)
      expect(activities_ids).not_to include(other_activity.id)
    end
  end

  describe '#create' do
    let(:json) { json_response[:activity] }

    it 'saves valid activity' do
      expect {
        post "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token, activity: activity_params
      }.to change(application.activities, :count).by(1)

      expect(response.status).to eq(201)

      activity = Activity.last
      expect(activity.trigger).not_to be(nil)
      as_json = S2sApi::V1::ActivitySerializer.new(activity).as_json(root: false)
      expect(json).to eq(as_json)
    end

    it 'not saves invalid activity' do
      expect {
        post "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token, activity: {}
      }.not_to change(Activity, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token, activity: {}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:name)
    end

    it 'assigns list of beacons/zones' do
      beacon_ids = FactoryGirl.create_list(:beacon, 2, account: admin.account).map(&:id)

      expect {
        post "/s2s_api/v1/applications/#{application.id}/activities.json",
          access_token: admin_access_token.token,
          activity: activity_params.deep_merge(trigger_attributes: {beacon_ids: beacon_ids})
      }.to change(TriggersSource, :count).by(2)

      activity = Activity.last
      expect(activity.trigger.beacons.count).to eq(2)
      expect(activity.trigger.beacon_ids).to match_array(beacon_ids)
    end

    it 'requires at least one beacon/zone' do
      expect {
        post "/s2s_api/v1/applications/#{application.id}/activities.json",
          access_token: admin_access_token.token,
          activity: activity_params.deep_merge(trigger_attributes: {beacon_ids: []})
      }.not_to change(TriggersSource, :count)

      expect(json_response[:errors]).to have_key(:"trigger.triggers_sources")
    end

    describe 'coupon activity' do
      let(:subject) {
        post "/s2s_api/v1/applications/#{application.id}/activities.json",
          access_token: admin_access_token.token,
          activity: coupon_activity_params
      }
      let(:coupon) { Coupon.last }
      let(:base_coupon_activity_params) {
        activity_params.merge({
          scheme: 'coupon',
          coupon_attributes: {
            name: 'Coupon name',
            title: 'Coupon title',
            description: 'Coupon description'
          }
        })
      }

      after check_json: true do
        coupon_activity_params[:coupon_attributes].each do |attr,value|
          expect(json[:coupon]).to have_key(attr)
          expect(coupon.send(attr)).to eq(value)
        end
      end

      describe 'with default template' do
        let(:coupon_activity_params) { base_coupon_activity_params.deep_merge(coupon_attributes: {template: 'template_1'}) }

        it 'succeeds', check_json: true do
          expect{ subject }.to change(Coupon, :count).by(1)
          expect(response.status).to eq(201)

          expect(json).to have_key(:coupon)
          expect(json[:coupon]).not_to have_key(:encoding_type)
          expect(json[:coupon]).not_to have_key(:button_link)
        end
      end

      describe 'with button' do
        let(:coupon_activity_params) { base_coupon_activity_params.deep_merge(coupon_attributes: {
          template: 'template_5',
          button_label: 'Button',
          button_link: 'http://example.com/button',
          button_font_color: '000',
          button_background_color: 'fff'
        }) }

        it 'succeeds', check_json: true do
          expect{ subject }.to change(Coupon, :count).by(1)
        end
      end

      describe 'with qr code' do
        let(:coupon_activity_params) { base_coupon_activity_params.deep_merge(coupon_attributes: {
          template: 'template_4',
          identifier_number: '1',
          unique_identifier_number: '2',
          encoding_type: 'qr_code'
        }) }

        it 'succeeds', check_json: true do
          expect{ subject }.to change(Coupon, :count).by(1)
        end
      end

      describe 'with images' do
        let(:coupon_activity_params) { base_coupon_activity_params.deep_merge(coupon_attributes: {
          template: 'template_1',
          image_attributes: {
            type: 'image',
            file: image
          }
        }) }

        it 'saves coupon images' do
          expect{ subject }.to change(CouponImage, :count).by(2)

          expect(coupon.image.file.url).to match(/image\.jpg$/)
          expect(coupon.logo.file.url).to match(/images\/preview\/logo\.png/)

          expect(json[:coupon][:image]).to have_key(:url)
          expect(json[:coupon][:image][:url]).to eq(coupon.image.file.url)
        end
      end
    end

    describe 'custom activity' do
      let(:custom_activity_params) {
        activity_params.merge({
          scheme: 'custom',
          custom_attributes_attributes: [
            {name: 'foo', value: 'Foo'},
            {name: 'bar', value: 'Bar'}
          ]
        })
      }

      it 'succeeds' do
        expect {
          post "/s2s_api/v1/applications/#{application.id}/activities.json", access_token: admin_access_token.token, activity: custom_activity_params
        }.to change(CustomAttribute, :count).by(2)

        activity = Activity.last
        expect(activity.custom_attributes.count).to eq(2)
        expect(activity.custom_attributes.pluck(:name)).to match_array(['foo', 'bar'])
        expect(activity.custom_attributes.pluck(:value)).to match_array(['Foo', 'Bar'])
      end
    end
  end

  describe '#update' do
    it 'updates activity' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/activities/#{url_activity.id}.json", access_token: admin_access_token.token, activity: activity_params
        url_activity.reload
      }.to change(url_activity, :name).to(activity_params[:name])
      expect(url_activity.scheme).to eq(activity_params[:scheme])
    end

    it 'not saves invalid activity' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/activities/#{url_activity.id}.json", access_token: admin_access_token.token, activity: {scheme: 'foo'}
        url_activity.reload
      }.not_to change(url_activity, :scheme)

      expect(response.status).to eq(422)

      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:scheme)
    end

    it 'updates activity associated trigger' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/activities/#{url_activity.id}.json",
          access_token: admin_access_token.token,
          activity: { trigger_attributes: {id: url_activity.trigger.id, event_type: 'leave'} }
        url_activity.trigger.reload
      }.to change(url_activity.trigger, :event_type).to('leave')
      expect(response.status).to eq(204)
    end

    describe 'coupon activity' do
      let(:subject) {
        put "/s2s_api/v1/applications/#{application.id}/activities/#{coupon_activity.id}.json",
          access_token: admin_access_token.token,
          activity: { coupon_attributes: {
            id: coupon_activity.coupon.id,
            template: 'template_5',
            button_label: 'Button',
            button_link: 'http://example.com/button',
            button_font_color: '000',
            button_background_color: 'fff',
            image_attributes: {
              id: coupon_activity.coupon.image.id,
              type: 'image',
              file: image
            }
          } }
      }

      it 'updates associated coupon images' do
        expect{
          subject
          coupon_activity.coupon.image.reload
        }.to change(coupon_activity.coupon.image, :url)

        expect{ subject }.not_to change(CouponImage, :count)
      end

      it 'updates associated coupon' do
        expect{
          subject
          coupon_activity.coupon.reload
        }.to change(coupon_activity.coupon, :template).to('template_5')

        expect{ subject }.not_to change(Coupon, :count)
      end
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/applications/#{application.id}/activities/#{url_activity.id}.json", access_token: admin_access_token.token
      }.to change(Activity, :count).by(-1)
      expect(response.status).to eq(204)
    end
  end
end
