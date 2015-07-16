###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe 'BeaconControl::PresenceExtension::Api::V1::Presence', type: :request do
  describe 'presence API' do
    let(:account)     { FactoryGirl.create(:account) }
    let(:application) { FactoryGirl.create(:application, account: account) }

    let!(:doorkeeper_app) do
      Doorkeeper::Application.create(
        name:         'FooApp',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        owner:        application
      )
    end

    let(:user)          { FactoryGirl.create(:user, application: application) }
    let(:mobile_device) { FactoryGirl.create(:mobile_device, user: user) }

    let!(:access_token) do
      Doorkeeper::AccessToken.create(
        resource_owner_id: mobile_device.id,
        application: doorkeeper_app,
        scopes: 'api'
      )
    end

    let!(:beacons) do
      [
        FactoryGirl.create(:beacon),
        FactoryGirl.create(:beacon),
        FactoryGirl.create(:beacon),
      ]
    end

    let(:zones) do
      [
        FactoryGirl.create(:zone),
        FactoryGirl.create(:zone),
        FactoryGirl.create(:zone),
      ]
    end

    let(:range_ids) do
      beacons.map(&:id)
    end

    let(:zone_ids) do
      zones.map(&:id)
    end

    before do
      beacons.each {|b| account.beacons << b }
      zones.each   {|z| account.zones   << z }
    end

    before do
      BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon('foo', range_ids[0]).create
      BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon('bar', range_ids[1]).create
      BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon('xyz', range_ids[1]).create

      BeaconControl::PresenceExtension::ZonePresence.present.for_user_and_zone('foo', zone_ids[0]).create
      BeaconControl::PresenceExtension::ZonePresence.present.for_user_and_zone('bar', zone_ids[1]).create
      BeaconControl::PresenceExtension::ZonePresence.present.for_user_and_zone('xyz', zone_ids[1]).create
    end

    describe 'show' do
      it 'returns users in requested ranges' do
        get '/api/v1/presence.json',
          ranges: range_ids, zones: nil, access_token: access_token.token

        expect(json_response).to eq({
          ranges: {
            range_ids[0].to_s.to_sym => ['foo'],
            range_ids[1].to_s.to_sym => ['bar', 'xyz'],
            range_ids[2].to_s.to_sym => []
          }
        })
      end

      it 'allows to scope ranges within app' do
        get '/api/v1/presence.json',
          ranges: [range_ids[1], 1_000_00], zones: nil, access_token: access_token.token

        expect(json_response).to eq({
          ranges: {
            range_ids[1].to_s.to_sym => ['bar', 'xyz']
          }
        })
      end

      it 'returns users in requested zones' do
        get '/api/v1/presence.json', {
          ranges: nil, zones: zone_ids, access_token: access_token.token
        }

        expect(json_response).to eq({
          zones: {
            zone_ids[0].to_s.to_sym => ['foo'],
            zone_ids[1].to_s.to_sym => ['bar', 'xyz'],
            zone_ids[2].to_s.to_sym => []
          }
        })
      end

      it 'returns users in all zones and ranges without params' do
        get '/api/v1/presence.json', { access_token: access_token.token }

        expect(json_response).to eq({
          ranges: {
            range_ids[0].to_s.to_sym => ['foo'],
            range_ids[1].to_s.to_sym => ['bar', 'xyz'],
            range_ids[2].to_s.to_sym => []
          },
          zones: {
            zone_ids[0].to_s.to_sym => ['foo'],
            zone_ids[1].to_s.to_sym => ['bar', 'xyz'],
            zone_ids[2].to_s.to_sym => []
          }
        })
      end
    end
  end
end
