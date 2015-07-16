###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::DwellTimeExtension::LeaveEvent do
  let(:store) { Moneta.new(:Memory) }

  let(:beacon) { double(triggers: [trigger]) }
  let(:trigger) { double(id: 1) }

  let(:event) { double(mobile_device: double(id: 1), proximity_id: 'bar', beacon: beacon) }
  let(:id)    { BeaconControl::DwellTimeExtension::Identifier.new(event, 1).to_s }

  before do
    store[id] = 'foo'
  end

  it 'cancels event in Sidekiq if exists' do
    expect(BeaconControl::BaseJob).to receive(:cancel).with('foo')

    described_class.new(event, store).call
  end
end
