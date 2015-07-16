###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::DwellTimeExtension::Identifier do
  before do
    allow(BeaconControl::DwellTimeExtension).to receive(:table_name_prefix) { 'foo_' }
  end

  let(:event) { double(mobile_device: double(id: 1), proximity_id: 'bar') }
  let(:trigger_id) { 1 }

  it 'generates sha1 key for given event' do
    attrs = { mobile_device_id: 1, proximity_id: 'bar', trigger_id: trigger_id }

    expect(described_class.new(event, 1).to_s).to eq(
      "foo_#{Digest::SHA1.hexdigest(attrs.to_json)}"
    )
  end
end
