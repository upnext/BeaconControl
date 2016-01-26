###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Registrations', type: :request, s2s: true do
  let(:admin_params) {
    {
      email: "new-admin@example.com",
      password: "secret1"
    }
  }
  let(:presence_extension) { ExtensionsRegistry.find('Presence') }

  describe '#create' do
    before do
      admin.reload
      ExtensionsRegistry.add(BeaconControl::PresenceExtension)
    end

    it 'saves valid admin account' do
      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: admin_params
      }.to change(Admin, :count).by(1)

      expect(response.status).to eq(201)

      admin = Admin.last
      expect(admin.email).to eq("new-admin@example.com")
      expect(admin.role).to eq("admin")

      expect(json_response[:admin]).to eq(S2sApi::V1::AdminSerializer.new(admin, root: false).as_json)
    end

    it 'creates test application' do
      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: admin_params
      }.to change(Application.where(test: true), :count).by(1)

      test_app = Application.last
      expect(test_app.extension_active?(presence_extension)).to eq(true)
      expect(test_app.account.active_extensions).to include(presence_extension)
    end

    it 'does not create test application if configured' do
      expect(AppConfig).to receive(:create_test_app_on_new_account).once.and_return(false)

      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: admin_params
      }.not_to change(Application.where(test: true), :count)
    end

    it 'does not save invalid admin' do
      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: {}
      }.not_to change(Admin, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post "/s2s_api/v1/admins.json",
        client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: {}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:email)
    end

    it 'authorizes request' do
      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: 'wrong-secret', admin: admin_params
      }.not_to change(Admin, :count)

      expect(response.status).to eq(403)
    end

    it 'prevents registration if registerable is turned off in AppConfig' do
      allow(AppConfig).to receive(:registerable).and_return(false)

      expect {
        post "/s2s_api/v1/admins.json",
          client_id: doorkeeper_app.uid, client_secret: doorkeeper_app.secret, admin: admin_params
      }.not_to change(Admin, :count)

      expect(response.status).to eq(403)
    end

  end
end
