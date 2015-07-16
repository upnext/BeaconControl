###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'
require 'support/s2s_api_shared_context'

RSpec.describe 'S2sApi::V1::Zones', type: :request, s2s: true do
  let!(:application) { FactoryGirl.create(:application, account: admin.account) }
  let!(:test_application) { FactoryGirl.create(:application, account: admin.account, test: true) }

  it 'returns list of colors' do
    get '/s2s_api/v1/zone_colors.json', access_token: admin_access_token.token

    expect(json_response[:colors].map {|c| c[:color] }).to eq(ZoneColors.to_a)
  end
end

