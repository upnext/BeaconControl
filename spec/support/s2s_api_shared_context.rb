###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

RSpec.shared_context "S2S API shared", s2s: true do
  let(:admin)          { FactoryGirl.create(:admin) }
  let(:manager)        { FactoryGirl.create(:admin, account: admin.account, role: :beacon_manager) }
  let(:doorkeeper_app) do
    Doorkeeper::Application.create(
      name: 'S2SApp',
      redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
      owner: admin.account.brand
    )
  end
  let(:admin_access_token) do
    Doorkeeper::AccessToken.create(
      resource_owner_id: admin.id,
      application: doorkeeper_app,
      scopes: "s2s_api"
    )
  end
  let(:manager_access_token) do
    Doorkeeper::AccessToken.create(
      resource_owner_id: manager.id,
      application: doorkeeper_app,
      scopes: "s2s_api"
    )
  end
end
