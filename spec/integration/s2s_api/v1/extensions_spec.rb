###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Extensions', type: :request, s2s: true do
  let!(:application) { FactoryGirl.create(:application, :with_doorkeeper_app, account: admin.account) }

  before do
    ExtensionsRegistry.add(FooExtension)
  end

  describe '#activate' do
    it 'succeeds' do
      AccountExtension.create(account_id: admin.account_id, extension_name: FooExtension.registered_name)

      expect {
        put "/s2s_api/v1/applications/#{application.id}/extensions/#{FooExtension.registered_name}/activate",
          access_token: admin_access_token.token
      }.to change(application.application_extensions, :count).by(1)
      expect(response.status).to eq(204)
    end

    it 'checks application permissions' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/extensions/#{FooExtension.registered_name}/activate",
          access_token: manager_access_token.token
      }.not_to change(application.application_extensions, :count)
      expect(response.status).to eq(403)
    end

    it 'checks if extension is activated for account' do
      expect {
        put "/s2s_api/v1/applications/#{application.id}/extensions/#{FooExtension.registered_name}/activate",
          access_token: admin_access_token.token
      }.not_to change(application.application_extensions, :count)
    end
  end

  describe '#deactivate' do
    it 'succeeds' do
      AccountExtension.create(account_id: admin.account_id, extension_name: FooExtension.registered_name)
      application.activate_extension(FooExtension.registered_name)

      expect {
        put "/s2s_api/v1/applications/#{application.id}/extensions/#{FooExtension.registered_name}/deactivate",
          access_token: admin_access_token.token
      }.to change(application.application_extensions, :count).by(-1)
      expect(response.status).to eq(204)
    end
  end
end
