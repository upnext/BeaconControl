###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Admins', type: :request, s2s: true do
  let!(:user) { FactoryGirl.create(:admin, account: admin.account) }

  before do
    admin.reload
    manager.reload
  end

  describe '#index' do
    let(:json) { json_response[:admins] }
    let(:admins_ids) { json.map{|a| a[:id]} }

    it 'returns list of admin users' do
      get '/s2s_api/v1/admin/users.json', access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(3)

      expect(admins_ids).to match_array([admin.id, manager.id, user.id])
      expect(json.detect{|u| u[:id]==admin.id}).to eq(S2sApi::V1::AdminSerializer.new(admin).as_json(root: false))
      [:id, :email, :role].each do |key|
        expect(json.first).to have_key(key)
      end
    end

    it 'returns only self for manager' do
      get '/s2s_api/v1/admin/users.json', access_token: manager_access_token.token

      expect(json.size).to eq(1)

      expect(admins_ids).to include(manager.id)
      expect(admins_ids).not_to include(admin.id)
    end
  end

  describe '#create' do
    let(:json) { json_response[:admin] }

    it 'saves valid admin user' do
      expect {
        post '/s2s_api/v1/admin/users.json', access_token: admin_access_token.token, admin: {email: "john@example.com", role: "admin"}
      }.to change(Admin, :count).by(1) and
           change(admin.account.admins, :count).by(1)

      expect(response.status).to eq(201)

      john = Admin.last
      as_json = S2sApi::V1::AdminSerializer.new(john).as_json(root: false)

      expect(john.email).to eq("john@example.com")
      expect(john.role).to eq("admin")
      expect(john.account).to eq(admin.account)

      expect(json).to eq(as_json)
    end

    it 'not saves invalid admin user' do
      expect {
        post '/s2s_api/v1/admin/users.json', access_token: admin_access_token.token, admin: {}
      }.not_to change(Admin, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post '/s2s_api/v1/admin/users.json', access_token: admin_access_token.token, admin: {}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:email)
    end

    it 'sends confirmation email' do
      expect {
        post '/s2s_api/v1/admin/users.json', access_token: admin_access_token.token, admin: {email: "john@example.com", role: "admin"}
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it 'prevents beacon managers from creating admin users' do
      expect {
        post '/s2s_api/v1/admin/users.json', access_token: manager_access_token.token, admin: {email: "john@example.com", role: "admin"}
      }.not_to change(ActionMailer::Base.deliveries, :count)

      expect(response.status).to eq(403)
    end
  end

  describe '#update' do
    it 'updates admin account' do
      expect {
        put "/s2s_api/v1/admin/users/#{user.id}.json", access_token: admin_access_token.token, admin: {email: "john@example.com", role: "beacon_manager"}
        user.reload
      }.to change(user, :email).to("john@example.com") and
           change(user, :role).to("beacon_manager")
    end

    it 'prevents beacon manager from updating other admin users' do
      expect {
        put "/s2s_api/v1/admin/users/#{user.id}.json", access_token: manager_access_token.token, admin: {email: "john@example.com"}
        user.reload
      }.not_to change(user, :email)

      expect(response.status).to eq(403)
    end

    it 'prevents beacon manager from changing own role' do
      expect {
        put "/s2s_api/v1/admin/users/#{manager.id}.json", access_token: manager_access_token.token, admin: {role: "admin"}
        manager.reload
      }.not_to change(manager, :role)
    end

    it 'allows beacon manager to update self' do
      expect {
        put "/s2s_api/v1/admin/users/#{manager.id}.json", access_token: manager_access_token.token, admin: {email: "john@example.com"}
        manager.reload
      }.to change(manager, :email).to("john@example.com")

      expect(response.status).to eq(204)
    end

    it 'allows changing password' do
      expect {
        put "/s2s_api/v1/admin/users/#{user.id}.json", access_token: admin_access_token.token, admin: {password: "secret1", password_confirmation: "secret1"}
        user.reload
      }.to change(user, :encrypted_password)
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/admin/users/#{user.id}.json", access_token: admin_access_token.token
      }.to change(Admin, :count).by(-1)
      expect(response.status).to eq(204)
    end

    it 'nullify beacons/zones manager' do
      beacon = FactoryGirl.create(:beacon, manager: manager)
      zone = FactoryGirl.create(:zone, manager: manager)

      expect {
        delete "/s2s_api/v1/admin/users/#{manager.id}.json", access_token: admin_access_token.token
        beacon.reload
        zone.reload
      }.to change(beacon, :manager_id).from(manager.id).to(nil)
      expect(response.status).to eq(204)

      expect(zone.manager_id).to be(nil)
    end

    it 'prevents beacon manager from deleting admin users' do
      expect {
        delete "/s2s_api/v1/admin/users/#{user.id}.json", access_token: manager_access_token.token
      }.not_to change(Admin, :count)
      expect(response.status).to eq(403)
    end
  end
end
