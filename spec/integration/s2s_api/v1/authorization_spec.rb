###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 's2s_api/v1 authorization', type: :request, s2s: true do
  let(:client_id)     { doorkeeper_app.uid }
  let(:client_secret) { doorkeeper_app.secret }
  let(:email)         { admin.email }
  let(:password)      { 'secret123' }

  let(:params) do
    {
      client_id:     client_id,
      client_secret: client_secret,
      grant_type:    'password',
      email:         email,
      password:      password
    }
  end

  context 'when is valid' do
    it 'returns valid access token' do
      post '/s2s_api/v1/oauth/token', params

      expect(json_response[:access_token]).to be_present
      expect(json_response[:expires_in]).to eq(AppConfig.token_expires_in)
      expect(json_response[:token_type]).to eq('bearer')
    end

    it 'prevents accessing endpoint by not confrmed admins' do
      admin.update_attributes(confirmation_token: 'foo', confirmed_at: nil, confirmation_sent_at: 1.day.ago)
      post '/s2s_api/v1/oauth/token', params

      expect(response.status).to eq(401)
      expect(json_response).to have_key(:error)
    end

    it 'sets correct Doorkeeper::AccessToken scope' do
      expect {
        post '/s2s_api/v1/oauth/token', params
      }.to change(Doorkeeper::AccessToken, :count).by(1)
      access_token = Doorkeeper::AccessToken.last
      expect(access_token.scopes.to_s).to eq('s2s_api')
    end

    it 'updates admin last_sign_in_at' do
      Timecop.freeze(2100, 8, 3) do
        expect {
          post '/s2s_api/v1/oauth/token', params
        }.to change {
          admin.reload.last_sign_in_at.to_i
        }.to(DateTime.now.to_i)
      end
    end
  end

  context 'when is invalid' do
    let(:password) { 'invalid' }

    it 'responds with error message' do
      post '/s2s_api/v1/oauth/token', params

      expect(json_response).to have_key(:error)
      expect(json_response).to have_key(:error_description)
    end

    context 'having /api Doorkeeper application' do
      let(:application) { FactoryGirl.create(:application) }
      let(:doorkeeper_app) do
        Doorkeeper::Application.create(
          name: 'ApiApp',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
          owner: application
        )
      end

      it 'prevents using different endpoint OAuth applications' do
        post '/s2s_api/v1/oauth/token', params
        expect(json_response).to have_key(:error)
      end

      it 'prevents using /api OAuth endpoint tokens' do
        post '/api/v1/oauth/token', {
          client_id:     doorkeeper_app.uid,
          client_secret: doorkeeper_app.secret,
          grant_type:    'password',
          user_id:       'foobar',
          os:            'ios',
          environment:   'production',
          push_token:    'token-test'
        }

        get '/s2s_api/v1/beacons.json', access_token: json_response[:access_token]
        expect(response.status).to eq(403)
      end
    end
  end
end
