###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

describe BeaconTriggerSerializer do
  let!(:trigger) { FactoryGirl.create(:beacon_trigger) }
  let!(:activity) { FactoryGirl.create(:url_activity, trigger: trigger) }

  let(:serialized) { described_class.new(trigger).as_json(root: false) }

  it 'includes all needed attributes' do
    expect(serialized).to include(:id, :conditions, :range_ids, :action)
    serialized[:conditions].each { |condition| expect(condition).to include(:event_type, :type) }
    expect(serialized[:action]).to include(:id, :type, :name, :payload)
  end
end
