###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Applications', type: :request, s2s: true do
  let!(:app1) { FactoryGirl.create(:application, :with_doorkeeper_app, account: admin.account) }
  let!(:app2) { FactoryGirl.create(:application, :with_doorkeeper_app, account: admin.account) }

  describe '#index' do
    let(:json) { json_response[:applications] }
    let(:application_ids) { json.map{|a| a[:id]} }

    it 'returns list of applications' do
      get '/s2s_api/v1/applications.json', access_token: admin_access_token.token

      expect(response.status).to eq(200)
      expect(json.size).to eq(2)

      expect(application_ids).to match_array([app1.id, app2.id])
      expect(json.last).to eq(S2sApi::V1::ApplicationSerializer.new(app2).as_json(root: false))
      [:id, :name, :uid, :secret, :test].each do |key|
        expect(json.last).to have_key(key)
      end
    end

    it 'prevents beacon managers from accessing list of applications' do
      get '/s2s_api/v1/applications.json', access_token: manager_access_token.token

      expect(response.status).to eq(403)
    end
  end

  describe '#create' do
    let(:json) { json_response[:application] }

    it 'saves valid application' do
      expect {
        post '/s2s_api/v1/applications.json', access_token: admin_access_token.token, application: {name: "App1"}
      }.to change(Application, :count).by(1) and
           change(admin.applications, :count).by(1)

      expect(response.status).to eq(201)

      app = Application.last
      as_json = S2sApi::V1::ApplicationSerializer.new(app).as_json(root: false)

      expect(app.name).to eq("App1")
      expect(app.account).to eq(admin.account)

      expect(json).to eq(as_json)
    end

    it 'creates Doorkeeper API application' do
      expect {
        post '/s2s_api/v1/applications.json', access_token: admin_access_token.token, application: {name: "App1"}
      }.to change(Doorkeeper::Application.where(owner_type: "Application"), :count).by(1)

      api_app = Doorkeeper::Application.last
      expect(api_app.uid).to eq(json[:uid])
      expect(api_app.secret).to eq(json[:secret])
    end

    it 'not saves invalid application' do
      expect {
        post '/s2s_api/v1/applications.json', access_token: admin_access_token.token, application: {}
      }.not_to change(Application, :count)
      expect(response.status).to eq(422)
    end

    it 'returns validation errors' do
      post '/s2s_api/v1/applications.json', access_token: admin_access_token.token, application: {}

      expect(response.status).to eq(422)
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:name)
    end

    it 'prevents beacon managers from creating applications' do
      expect {
        post '/s2s_api/v1/applications.json', access_token: manager_access_token.token, application: {name: "App1"}
      }.not_to change(Application, :count)

      expect(response.status).to eq(403)
    end
  end

  describe '#update' do
    it 'updates application' do
      expect {
        put "/s2s_api/v1/applications/#{app1.id}.json", access_token: admin_access_token.token, application: {name: "Name3"}
        app1.reload
      }.to change(app1, :name).to("Name3")
    end

    it 'prevents updating test application name' do
      app1.update_attribute(:test, true)
      expect {
        put "/s2s_api/v1/applications/#{app1.id}.json", access_token: admin_access_token.token, application: {name: "Name3"}
        app1.reload
      }.not_to change(app1, :name)
    end

    it 'prevents beacon managers from updating applications' do
      expect {
        put "/s2s_api/v1/applications/#{app1.id}.json", access_token: manager_access_token.token, application: {name: "Name3"}
      }.not_to change(Application, :count)

      expect(response.status).to eq(403)
    end
  end

  describe '#destroy' do
    it 'succeeds' do
      expect {
        delete "/s2s_api/v1/applications/#{app1.id}.json", access_token: admin_access_token.token
      }.to change(Application, :count).by(-1)
      expect(response.status).to eq(204)
    end

    it 'prevents removing test applications' do
      app1.update_attribute(:test, true)
      expect {
        delete "/s2s_api/v1/applications/#{app1.id}.json", access_token: admin_access_token.token
      }.not_to change(Application, :count)
      expect(response.status).to eq(422)
    end

    it 'prevents beacon managers from removing applications' do
      expect {
        delete "/s2s_api/v1/applications/#{app1.id}.json", access_token: manager_access_token.token
      }.not_to change(Application, :count)

      expect(response.status).to eq(403)
    end
  end
end
