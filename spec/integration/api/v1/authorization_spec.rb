###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe 'api/v1 authorization', type: :request do
  let(:doorkeeper_app) do
    Doorkeeper::Application.create(
      name: 'FooApp',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
    )
  end
  let!(:application) do
    FactoryGirl.create(
      :application,
      doorkeeper_application: doorkeeper_app
    )
  end

  let(:user_id) { 'foobar' }
  let(:os)      { 'ios' }
  let(:token)   { 'token-test' }

  context 'when is valid' do
    let(:valid_params) do
      {
        client_id:     doorkeeper_app.uid,
        client_secret: doorkeeper_app.secret,
        grant_type:    'password',
        user_id:       user_id,
        os:            os,
        environment:   'production',
        push_token:    token
      }
    end

    it 'returns valid access token' do
      post '/api/v1/oauth/token', valid_params

      expect(json_response[:access_token]).to be_present
      expect(json_response[:expires_in]).to eq(AppConfig.token_expires_in)
      expect(json_response[:token_type]).to eq('bearer')
    end

    it 'creates Doorkeeper::AccessToken instance' do
      expect {
        post '/api/v1/oauth/token', valid_params
      }.to change(Doorkeeper::AccessToken, :count).by(1)
    end

    it 'sets correct Doorkeeper::AccessToken scope' do
      post '/api/v1/oauth/token', valid_params
      access_token = Doorkeeper::AccessToken.last
      expect(access_token.scopes.to_s).to eq('api')
    end

    context 'when mobile user is new' do
      it 'is created' do
        expect {
          post '/api/v1/oauth/token', valid_params
        }.to change(User, :count).by(1)
      end

      it 'assigns user to app via doorkeeper app' do
        post '/api/v1/oauth/token', valid_params

        user = User.where(client_id: user_id).first
        expect(user.application_id).to eq(application.id)
      end
    end

    context 'when client exists before in same application' do
      before do
        User.create(client_id: user_id, application: application)
      end

      it 'is not created' do
        expect {
          post '/api/v1/oauth/token', valid_params
        }.to_not change(User, :count)
      end
    end

    context 'when client exists with same id in other application' do
      let(:other_doorkeeper_app) do
        Doorkeeper::Application.create(
          name: 'BarApp',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
        )
      end

      let(:other_application) do
        FactoryGirl.create(
          :application,
          doorkeeper_application: other_doorkeeper_app
        )
      end

      before do
        User.create(client_id: user_id, application: other_application)
      end

      it 'is created' do
        expect {
          post '/api/v1/oauth/token', valid_params
        }.to change(User, :count).by(1)
      end
    end

    context 'when mobile device for user is new' do
      it 'is created' do
        expect {
          post '/api/v1/oauth/token', valid_params
        }.to change(MobileDevice, :count).by(1)
      end
    end

    context 'when mobile device for user existed before' do
      let(:user) do
        User.create(client_id: user_id, application: application)
      end
      let!(:mobile_device) do
        FactoryGirl.create(:mobile_device,
          user:        user,
          os:          os,
          push_token:  token,
          environment:     'production'
        )
      end

      it 'is not created' do
        expect {
          post '/api/v1/oauth/token', valid_params
        }.to_not change(MobileDevice, :count)
      end

      it 'updates it last_sign_in_at' do
        Timecop.freeze(2100, 8, 3) do
          expect {
            post '/api/v1/oauth/token', valid_params
          }.to change {
            mobile_device.reload.last_sign_in_at.to_i
          }.to(DateTime.now.to_i)
        end
      end
    end
  end

  context 'when is invalid' do
    let(:invalid_params) do
      {
        client_id: 'test',
        grant_type: 'password',
        user_id: 'test'
      }
    end

    it 'does not create mobile user' do
      expect {
        post '/api/v1/oauth/token', invalid_params
      }.to_not change(User, :count)
    end

    it 'does not create mobile device' do
      expect {
        post '/api/v1/oauth/token', invalid_params
      }.to_not change(MobileDevice, :count)
    end

    it 'responds with error message' do
      post '/api/v1/oauth/token', invalid_params

      expect(json_response).to have_key(:error)
      expect(json_response).to have_key(:error_description)
    end
  end
end
