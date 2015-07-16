###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Zones', type: :request, s2s: true do
  let!(:application) { FactoryGirl.create(:application, account: admin.account) }
  let!(:test_application) { FactoryGirl.create(:application, account: admin.account, test: true) }
  let!(:zone1) { FactoryGirl.create(:zone, account: admin.account) }
  let!(:zone2) { FactoryGirl.create(:zone, account: admin.account, manager: manager) }
  let!(:beacon) { FactoryGirl.create(:beacon, manager: manager, zone: zone2) }

  describe '#index' do
    let(:json) { json_response[:zones] }
    let(:zone_ids) { json.map{|z| z[:id]} }

    it 'returns list of zones' do
      get '/s2s_api/v1/zones.json', access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(2)

      expect(zone_ids).to match_array([zone1.id, zone2.id])
      expect(json.last).to eq(S2sApi::V1::ZoneSerializer.new(zone2).as_json(root: false))
      [:id, :name, :beacons, :beacon_ids].each do |key|
        expect(json.last).to have_key(key)
      end
    end

    it 'searches list of zones by name' do
      get '/s2s_api/v1/zones.json', name: zone1.name, access_token: admin_access_token.token

      expect(json.size).to eq(1)
      expect(zone_ids).to include(zone1.id)
    end

    it 'scopes list of zones for manager' do
      get '/s2s_api/v1/zones.json', access_token: manager_access_token.token

      expect(json.size).to eq(1)

      expect(zone_ids).to include(zone2.id)
      expect(zone_ids).not_to include(zone1.id)
    end

    it 'includes zone beacons' do
      get '/s2s_api/v1/zones.json', access_token: manager_access_token.token

      expect(json.first).to have_key(:beacon_ids)
      expect(json.first[:beacon_ids].size).to eq(1)

      expect(json.first[:beacon_ids]).to match_array(manager.beacons.pluck(:id))

      expect(json.first).to have_key(:beacons)
      expect(json.first[:beacons].size).to eq(1)

      expect(json.first[:beacons]).to eq(
        [S2sApi::V1::BeaconSerializer.new(beacon).attributes]
      )
    end
  end

  describe '#create' do
    let(:json) { json_response[:zone] }

    it 'saves valid zone' do
      expect {
        post '/s2s_api/v1/zones.json', access_token: admin_access_token.token, zone: {name: "Zone3", description: "Desc3", color: ZoneColors.sample}
      }.to change(application.zones, :count).by(1)

      expect(response.status).to eq(201)

      zone = Zone.last
      as_json = S2sApi::V1::ZoneSerializer.new(zone).as_json(root: false)

      expect(zone.name).to eq("Zone3")
      expect(zone.description).to eq("Desc3")
      expect(zone.manager).to be_nil
      expect(zone.applications_zones).not_to be_empty

      expect(json).to eq(as_json)
    end

    it 'does not save invalid zone' do
      expect {
        post '/s2s_api/v1/zones.json', access_token: admin_access_token.token, zone: {description: "Desc3"}
      }.not_to change(Zone, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post '/s2s_api/v1/zones.json', access_token: admin_access_token.token, zone: {}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:name)
    end

    it 'assigns zone manager' do
      post '/s2s_api/v1/zones.json', access_token: admin_access_token.token, zone: {name: "Name3", color: ZoneColors.sample }
      expect(Zone.last.manager).to eq(nil)

      post '/s2s_api/v1/zones.json', access_token: admin_access_token.token, zone: {name: "Name3", manager_id: manager.id, color: ZoneColors.sample }
      expect(Zone.last.manager).to eq(manager)
    end

    it 'assigns manager himself as zone manager' do
      expect {
        post '/s2s_api/v1/zones.json', access_token: manager_access_token.token, zone: {name: "Name3", color: ZoneColors.sample }
      }.to change(manager.zones, :count).by(1)

      expect(Zone.last.manager).to eq(manager)
    end

    context 'add beacon' do
      let(:subject) {
        post '/s2s_api/v1/zones.json', access_token: access_token, zone: {name: "Name3", beacon_ids: [beacon_to_add.id], color: ZoneColors.sample }
        beacon_to_add.reload
      }
      let(:beacon_to_add) { FactoryGirl.create(:beacon, account: admin.account, zone: zone1) }
      let(:access_token)  { manager_access_token.token }

      context 'with other manager' do
        it 'fails' do
          expect { subject }.not_to change(beacon_to_add, :zone)
        end
      end

      context 'with manager to zone by manager' do
        let(:beacon_to_add) { beacon }
        it 'succeeds' do
          expect { subject }.to change(beacon_to_add, :zone)
          expect(beacon_to_add.zone).to eq(Zone.last)
        end
      end

      context 'without manager to zone without manager' do
        let(:access_token)  { admin_access_token.token }
        it 'succeeds' do
          expect { subject }.to change(beacon_to_add, :zone)
        end
      end
    end
  end

  describe '#update' do
    it 'updates zone' do
      expect {
        put "/s2s_api/v1/zones/#{zone1.id}.json", access_token: admin_access_token.token, zone: {name: "Name3", description: "Desc3"}
        zone1.reload
      }.to change(zone1, :name).to("Name3") and
           change(zone1, :description).to("Desc3")
    end

    it 'allows manager to update only own zones' do
      expect {
        put "/s2s_api/v1/zones/#{zone2.id}.json", access_token: manager_access_token.token, zone: {name: "Name3"}
        zone2.reload
      }.to change(zone2, :name)
      expect(response.status).to eq(204)

      expect {
        put "/s2s_api/v1/zones/#{zone1.id}.json", access_token: manager_access_token.token, zone: {name: "Name4"}
        zone1.reload
      }.not_to change(zone1, :name)
      expect(response.status).to eq(403)
    end

    it 'allows superuser to manage all zones' do
      expect {
        put "/s2s_api/v1/zones/#{zone2.id}.json", access_token: admin_access_token.token, zone: {name: "Name3"}
        zone2.reload
      }.to change(zone2, :name)
      expect(response.status).to eq(204)
    end

    it 'removes other manager beacons from zone when changing manager' do
      other_manager = FactoryGirl.create(:admin, account: admin.account, role: :beacon_manager)

      expect {
        put "/s2s_api/v1/zones/#{zone2.id}.json", access_token: admin_access_token.token, zone: {manager_id: other_manager.id}
        zone2.reload
      }.to change(zone2.beacons, :count).by(-1)
      expect(beacon.reload.zone).to be_nil
    end

    it 'adds beacon to zone' do
      other_beacon = FactoryGirl.create(:beacon, manager: manager)

      expect {
        put "/s2s_api/v1/zones/#{zone2.id}.json", access_token: admin_access_token.token, zone: {beacon_ids: [other_beacon.id]}
        other_beacon.reload
      }.to change(other_beacon, :zone).to(zone2)
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/zones/#{zone1.id}.json", access_token: admin_access_token.token
      }.to change(Zone, :count).by(-1)
      expect(response.status).to eq(204)
    end

    it 'fails manager removing not his zone' do
      expect {
        delete "/s2s_api/v1/zones/#{zone1.id}.json", access_token: manager_access_token.token
      }.not_to change(Zone, :count)
      expect(response.status).to eq(403)
    end
  end

  describe '#beacons' do
    let(:json) { json_response[:ranges] }
    let(:beacon_ids) { json.map{|b| b[:id]} }
    let!(:beacon1) { FactoryGirl.create(:beacon, account: admin.account, zone: zone1) }
    let!(:beacon2) { FactoryGirl.create(:beacon, account: admin.account) }

    it 'returns list of beacons in zone' do
      get "/s2s_api/v1/zones/#{zone1.id}/beacons.json", access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(1)
      expect(beacon_ids).to include(beacon1.id)
      expect(beacon_ids).not_to include(beacon2.id)

      expect(json.first).to eq(S2sApi::V1::BeaconSerializer.new(beacon1).as_json(root: false))
      [:id, :name, :location, :proximity_id].each do |key|
        expect(json.last).to have_key(key)
      end
    end

    it "allows manager to fetch only his zone's beacons " do
      get "/s2s_api/v1/zones/#{zone2.id}/beacons.json", access_token: manager_access_token.token
      expect(response.status).to eq(200)

      get "/s2s_api/v1/zones/#{zone1.id}/beacons.json", access_token: manager_access_token.token
      expect(response.status).to eq(403)
    end
  end
end
