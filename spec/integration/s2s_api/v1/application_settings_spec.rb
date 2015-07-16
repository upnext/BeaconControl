###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::ApplicationSettings', type: :request, s2s: true do
  let!(:application) { FactoryGirl.create(:application, :with_doorkeeper_app, account: admin.account) }
  let(:setting) { ApplicationSetting.create(setting_params.merge(application_id: application.id, type: "ApplicationSetting::StringSetting")) }
  let(:setting_params) {
    {
      extension_name: "Foo",
      type: "string",
      key: "username",
      value: "John"
    }
  }

  before do
    ExtensionsRegistry.add(FooExtension)
    application.activate_extension(FooExtension.registered_name)
  end

  describe '#index' do
    let(:json) { json_response[:application_settings] }

    it 'returns available settings' do
      get "/s2s_api/v1/applications/#{application.id}/application_settings.json",
        access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(3)

      expect(json.map{|setting| setting[:key]}).to match_array(["username", "password", "file"])
      expect(json.map{|setting| setting[:value]}.uniq).to eq([nil])
    end

    it 'includes saved settings' do
      setting.reload
      get "/s2s_api/v1/applications/#{application.id}/application_settings.json",
        access_token: admin_access_token.token

      expect(json.size).to eq(3)
      expect(json.map{|setting| setting[:value]}).to match_array(["John", nil, nil])

      username = json.detect{|s| s[:key] == 'username'}
      expect(username[:id]).to eq(setting.id)
      expect(username[:extension_name]).to eq(setting.extension_name)
      expect(username[:value]).to eq(setting.value)
      expect(username[:key]).to eq(setting.key)
    end
  end

  describe '#update' do
    it 'saves valid setting' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
          access_token: admin_access_token.token, application_settings: [setting_params]
      }.to change(ApplicationSetting, :count).by(1) and
           change(application.application_settings, :count).by(1)

      expect(response.status).to eq(204)

      username = ApplicationSetting.last
      expect(username.extension_name).to eq("Foo")
      expect(username.type).to eq("string")
      expect(username.key).to eq("username")
      expect(username.value).to eq("John")
    end

    it 'not saves invalid setting' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
          access_token: admin_access_token.token, application_settings: [{extension_name: "Foo"}]
      }.not_to change(ApplicationSetting, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
        access_token: admin_access_token.token, application_settings: [setting_params.merge(key: "foo")]

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:application_settings)
      expect(json_response[:application_settings][0]).to have_key(:errors)
      expect(json_response[:application_settings][0][:errors]).to have_key(:key)
    end

    it 'checks application ownership' do
      other_admin = FactoryGirl.create(:admin)
      other_access_token = Doorkeeper::AccessToken.create(
        resource_owner_id: other_admin.id,
        application: doorkeeper_app,
        scopes: "s2s_api"
      )

      expect {
        put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
          access_token: other_access_token.token, application_settings: [setting_params]
      }.not_to change(ApplicationSetting, :count)
      expect(response.status).to eq(404)
    end

    it 'saves multiple settings at once' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
          access_token: admin_access_token.token, application_settings: [setting_params, setting_params.merge(key: "password")]
      }.to change(ApplicationSetting, :count).by(2) and
           change(application.application_settings, :count).by(2)
    end

    it 'removes setting' do
      setting.reload
      expect {
        put "/s2s_api/v1/applications/#{application.id}/application_settings.json",
          access_token: admin_access_token.token, application_settings: [{
          extension_name: "Foo",
          key: "username",
        }]
      }.to change(ApplicationSetting, :count).by(-1) and
           change(application.application_settings, :count).by(-1)
    end

    it 'updates setting' do
      expect {
      put "/s2s_api/v1/applications/#{application.id}/application_settings",
        access_token: admin_access_token.token, application_settings: [setting_params.merge(value: "Jane")]
        setting.reload
      }.to change(setting, :value).to("Jane")
    end
  end
end
