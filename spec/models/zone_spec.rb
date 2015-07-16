###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe Zone do
  describe 'validation' do
    let(:account) { FactoryGirl.create(:account) }
    let(:subject) { described_class.new(attributes) }
    let(:attributes) { {name: 'Zone', manager: manager, account: account, color: ZoneColors.list.sample } }

    context 'manger' do
      context 'with admin role' do
        let(:manager) { FactoryGirl.create(:admin, role: 'admin', account: account) }
        it { should_not be_valid }
      end

      context 'with beacon_manager role' do
        let(:manager) { FactoryGirl.create(:admin, role: 'beacon_manager', account: account) }
        it { should be_valid }
      end
    end
  end
end
