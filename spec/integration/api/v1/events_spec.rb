###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe 'Api::V1::Events', type: :request do
  describe 'events API' do
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
      it 'Exectues event processor process' do
        expect(EventProcessor).to receive(:process)
        post '/api/v1/events.json', {
          events: [{ action_id: 1}, { action_id: 2}],
          access_token: access_token.token
        }
      end

      it 'Returns 200 on success' do
        post '/api/v1/events.json', {
          events: [{ action_id: 1}, { action_id: 2}],
          access_token: access_token.token
        }
        expect(response.status).to eq(200)
      end

      it 'Returns 401 if not authorized' do
        post '/api/v1/events.json', {
          events: [{ action_id: 1}, { action_id: 2}],
          access_token: 'bad-token'
        }

        expect(response.status).to eq(401)
      end

      describe 'Sidekiq queue', type: :async do
        before do
          post '/api/v1/events.json', {
            events: [{ action_id: 1}, { action_id: 2}],
            access_token: access_token.token
          }
        end

        it 'gets enqueued EventJob job ' do
          expect(enqueued_jobs.size).to eq(1)
        end

        it 'is valid job' do
          job = enqueued_jobs.first

          expect(job[:job]).to eq(EventJob)

          expect(job[:args]).to eq([{
            events:        [{"action_id"=>"1"}, {"action_id"=>"2"}],
            application:   application,
            user:          user,
            mobile_device: mobile_device
          }])
        end
      end
    end
  end
end
