###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

describe 'S2sApi::V1::Passwords', type: :request, s2s: true do
  let(:doorkeeper_params) do
    {
      client_id: doorkeeper_app.uid,
      client_secret: doorkeeper_app.secret
    }
  end
  let(:email_params) { {email: admin.email } }
  let(:password_params) {
    {
      password: "secret1",
      password_confirmation: "secret1"
    }
  }

  describe '#create' do
    it 'saves new reset password token' do
      expect {
        post "/s2s_api/v1/password.json", doorkeeper_params.merge(admin: email_params)
        admin.reload
      }.to change(admin, :reset_password_token).from(nil)

      expect(response).to have_http_status :created
    end

    it 'returns validation errors' do
      post "/s2s_api/v1/password.json", doorkeeper_params.merge(admin: {email: 'foo@bar.com'})

      expect(response).to have_http_status :unprocessable_entity
      expect(json_response).to have_key(:errors)
      expect(json_response[:errors]).to have_key(:email)
    end

    it 'sends email with reset password token' do
      expect {
        post "/s2s_api/v1/password.json", doorkeeper_params.merge(admin: email_params)
        admin.reload
      }.to change(ActionMailer::Base.deliveries, :count)
    end

    it 'authorizes request' do
      expect {
        post "/s2s_api/v1/password.json", doorkeeper_params.merge(client_secret: 'wrong-secret', admin: email_params)
      }.not_to change(admin, :reset_password_token)

      expect(response).to have_http_status :forbidden
    end
  end

  describe '#update' do
    let(:token) do 
      ActionMailer::Base.deliveries.last.parts.first.body.raw_source.to_s[/.*reset_password_token=([^ ]*)/, 1]
    end

    it 'validates reset token' do
      expect {
        put "/s2s_api/v1/password.json",
            doorkeeper_params.merge(admin: password_params.merge({reset_password_token: "foo"}))
      }.not_to change(admin, :encrypted_password)

      expect(response).to have_http_status :unprocessable_entity
      expect(json_response[:errors]).to have_key(:reset_password_token)
    end

    it 'changes password' do
      admin.send_reset_password_instructions

      expect {
        put "/s2s_api/v1/password.json",
            doorkeeper_params.merge(admin: password_params.merge({reset_password_token: token}))
        admin.reload
      }.to change(admin, :encrypted_password)

      expect(response).to have_http_status :no_content
      expect(admin.reset_password_token).to be(nil)
    end
  end
end
