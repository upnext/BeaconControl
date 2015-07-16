###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe 'Api::V1::Configurations', type: :request do
  describe '#index' do
    let(:application) { FactoryGirl.create(:application) }

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

    describe 'index' do
      it 'Returns 200 on success' do
        get '/api/v1/configurations.json', access_token: access_token.token

        expect(response.status).to eq(200)
      end

      it 'Returns 401 if not authorized' do
        get '/api/v1/configurations.json', access_token: 'bad-token'

        expect(response.status).to eq(401)
      end

      context 'when application has no active extensions' do
        before { get '/api/v1/configurations.json', access_token: access_token.token }

        it 'returns default extensions configuration' do
          expect(json_response).to eq(ExtensionData::Triggers.new(application).as_json)
        end
      end

    end
  end
end
