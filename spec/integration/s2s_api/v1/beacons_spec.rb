###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Beacons', type: :request, s2s: true do
  let!(:application) { FactoryGirl.create(:application, account: admin.account) }
  let!(:test_application) { FactoryGirl.create(:application, account: admin.account, test: true) }
  let!(:beacon1) { FactoryGirl.create(:beacon, account: admin.account) }
  let!(:beacon2) { FactoryGirl.create(:beacon, account: admin.account, manager: manager) }

  let(:beacon_params) {
    {
      name: "Beacon",
      account_id: admin.account_id,
      uuid: "00000000-0000-0000-0000-000000000000",
      major: 0,
      minor: 0
    }
  }

  let(:activity_attributes) {
    {
      activity: {
        name: 'Test notification',
        trigger_attributes: {
          test: true,
          event_type: 'far'
        },
        custom_attributes_attributes: [{
          name: 'Custon name',
          value: 'Custom value'
        },
        {
          name: 'Second custon name',
          value: 'Second custom value'
        }]
      }
    }
  }

  describe '#index' do
    let(:json) { json_response[:ranges] }
    let(:beacon_ids) { json.map{|b| b[:id]} }

    it 'returns list of beacons' do
      get '/s2s_api/v1/beacons.json', access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(2)

      expect(beacon_ids).to match_array([beacon1.id, beacon2.id])
      expect(json.last).to eq(S2sApi::V1::BeaconSerializer.new(beacon2).as_json(root: false))
      [:id, :name, :location, :proximity_id].each do |key|
        expect(json.last).to have_key(key)
      end
    end

    it 'searches list of beacons by name' do
      get '/s2s_api/v1/beacons.json', name: beacon1.name, access_token: admin_access_token.token

      expect(json.size).to eq(1)
      expect(beacon_ids).to include(beacon1.id)
    end

    it 'scopes list of beacons for manager' do
      get '/s2s_api/v1/beacons.json', access_token: manager_access_token.token

      expect(json.size).to eq(1)

      expect(beacon_ids).to include(beacon2.id)
      expect(beacon_ids).not_to include(beacon1.id)
    end
  end

  describe '#create' do
    let(:json) { json_response[:range] }

    it 'saves valid beacon' do
      expect {
        post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: beacon_params
      }.to change(Beacon, :count).by(1) and
           change(application.beacons, :count).by(1)

      expect(response.status).to eq(201)

      beacon = Beacon.last
      as_json = S2sApi::V1::BeaconSerializer.new(beacon).as_json(root: false)

      expect(beacon.name).to eq("Beacon")
      expect(beacon.account_id).to eq(admin.account_id)
      expect(beacon.uuid).to eq("00000000-0000-0000-0000-000000000000")
      expect(beacon.major).to eq("0")
      expect(beacon.minor).to eq("0")

      expect(beacon.manager).to be_nil
      expect(beacon.applications_beacons).not_to be_empty

      expect(json).to eq(as_json)
    end

    it 'not saves invalid beacon' do
      expect {
        post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: {}
      }.not_to change(Beacon, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: {uuid: 0, major: "major", floor: 11}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:uuid)
      expect(json_response[:errors]).to have_key(:major)
      expect(json_response[:errors]).to have_key(:minor)
      expect(json_response[:errors]).to have_key(:floor)
    end

    it 'not assigns any manager by default if submitted by admin' do
      post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: beacon_params
      expect(Beacon.last.manager).to eq(nil)
    end

    it 'assigns beacon manager' do
      post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: beacon_params.merge({manager_id: manager.id})
      expect(Beacon.last.manager).to eq(manager)
    end

    it 'assigns manager himself as beacon manager' do
      expect {
        post '/s2s_api/v1/beacons.json', access_token: manager_access_token.token, beacon: beacon_params
      }.to change(manager.beacons, :count).by(1)

      expect(Beacon.last.manager).to eq(manager)
    end

    context 'test notification' do
      it 'creates activity if test flag set to true' do
        expect {
          post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token, beacon: beacon_params.merge(activity_attributes)
        }.to change(Activity, :count).by(1)
        expect(response.status).to eq(201)

        beacon = Beacon.last
        activity = Activity.last

        expect(activity.test).to eq(true)
        expect(activity.trigger).not_to be_nil
        expect(activity.trigger.beacons).to include(beacon)
        expect(activity.custom_attributes.count).to eq(1)
        expect(beacon.triggers).to include(activity.trigger)
      end

      it 'discards activity if test flag set to false' do
        expect {
          post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token,
            beacon: beacon_params.merge(activity_attributes.deep_merge({activity: {trigger_attributes: {test: false}}}))
        }.not_to change(Activity, :count)
        expect(response.status).to eq(201)

        beacon = Beacon.last
        expect(beacon.triggers).to be_empty
      end

      it 'adds validation errors' do
        expect {
          post '/s2s_api/v1/beacons.json', access_token: admin_access_token.token,
            beacon: beacon_params.merge(activity_attributes.deep_merge({activity: {name: nil}}))
        }.not_to change(Beacon, :count)
        expect(response.status).to eq(422)

        expect(json_response).to have_key(:errors)
        expect(json_response[:errors]).to have_key(:test_activity)
      end
    end
  end

  describe '#update' do
    it 'updates beacon' do
      expect {
        put "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: admin_access_token.token, beacon: beacon_params
        beacon1.reload
      }.to change(beacon1, :name).to(beacon_params[:name]) and
           change(beacon1, :uuid).to(beacon_params[:uuid])
    end

    it 'allows manager to update only own beacons' do
      expect {
        put "/s2s_api/v1/beacons/#{beacon2.id}.json", access_token: manager_access_token.token, beacon: {name: "New name"}
        beacon2.reload
      }.to change(beacon2, :name)
      expect(response.status).to eq(204)

      expect {
        put "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: manager_access_token.token, beacon: {name: "New name"}
        beacon1.reload
      }.not_to change(beacon1, :name)
      expect(response.status).to eq(403)
    end

    it 'allows superuser to manage all beacon' do
      expect {
        put "/s2s_api/v1/beacons/#{beacon2.id}.json", access_token: admin_access_token.token, beacon: {name: "New name"}
        beacon2.reload
      }.to change(beacon2, :name)
      expect(response.status).to eq(204)
    end

    context 'assigning beacon to zone' do
      let(:subject) { beacon_to_move.zone }
      let(:zone) { FactoryGirl.create(:zone, account: admin.account, manager: zone_manager) }

      before do
        put "/s2s_api/v1/beacons/#{beacon_to_move.id}.json", access_token: admin_access_token.token, beacon: {zone_id: zone.id}
        beacon_to_move.reload
      end

      context 'without manager' do
        let(:zone_manager) { nil }

        context 'for beacon without manager' do
          let(:beacon_to_move) { beacon1 }
          it { should eq(zone) }
        end

        context 'for beacon with manager' do
          let(:beacon_to_move) { beacon2 }

          it { should_not eq(zone) }
          it { should eq(nil) }
          it 'fails' do
            expect(json_response).to have_key(:errors)
            expect(json_response[:errors]).to have_key(:zone_id)
          end
        end
      end

      context 'with manager' do
        let(:beacon_to_move) { beacon2 }

        context 'when manager is destination zone manager' do
          let(:zone_manager) { beacon_to_move.manager }
          it { should eq(zone) }
        end

        context 'when destination zone manager is different' do
          let(:zone_manager) { FactoryGirl.create(:admin, account: admin.account, role: :beacon_manager) }

          it { should_not eq(zone) }
          it { should eq(nil) }
          it 'fails' do
            expect(json_response).to have_key(:errors)
            expect(json_response[:errors]).to have_key(:zone_id)
          end
        end
      end
    end

    context 'test notification' do
      it 'creates activity if not present' do
        expect {
          put "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: admin_access_token.token,
            beacon: beacon_params.merge(activity_attributes)
          beacon1.reload
        }.to change(Activity, :count).by(1)

        activity = Activity.last
        expect(beacon1.triggers).to include(activity.trigger)
        expect(activity.trigger.beacons).to include(beacon1)
      end

      it 'updates activity if present' do
        beacon1.update_test_activity(activity_attributes[:activity].deep_merge({scheme: 'custom', trigger_attributes: {type: 'BeaconTrigger'}}))
        expect(beacon1.test_activity.custom_attributes.count).to eq(1)

        expect {
          put "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: admin_access_token.token,
            beacon: beacon_params.merge(activity_attributes.deep_merge(activity: {name: "New name"}))
          beacon1.reload
        }.not_to change(Activity, :count)

        expect(beacon1.triggers.first.activity.name).to eq("New name")
      end

      it 'adds validation errors' do
        beacon1.update_test_activity(activity_attributes[:activity].deep_merge({scheme: 'custom', trigger_attributes: {type: 'BeaconTrigger'}}))

        expect {
          put "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: admin_access_token.token,
            beacon: beacon_params.merge(activity_attributes.deep_merge(activity: {name: nil}))
        }.not_to change(beacon1.test_activity.reload, :name)
        expect(response.status).to eq(422)

        expect(json_response).to have_key(:errors)
        expect(json_response[:errors]).to have_key(:test_activity)
      end
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: admin_access_token.token
      }.to change(Beacon, :count).by(-1)
      expect(response.status).to eq(204)
    end

    it 'fails manager removing not his beacon' do
      expect {
        delete "/s2s_api/v1/beacons/#{beacon1.id}.json", access_token: manager_access_token.token
      }.not_to change(Beacon, :count)
      expect(response.status).to eq(403)
    end
  end

  describe '#batch_destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/beacons.json", access_token: admin_access_token.token, ids: [beacon1.id, beacon2.id]
      }.to change(Beacon, :count).by(-2)
      expect(response.status).to eq(204)
    end

    it 'fails manager removing not his beacon' do
      expect {
        delete "/s2s_api/v1/beacons.json", access_token: manager_access_token.token, ids: [beacon1.id]
      }.not_to change(Beacon, :count)
    end
  end
end
