###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::AnalyticsExtension::Event do
  let(:application) { FactoryGirl.create(:application) }

  let(:event) { FactoryGirl.build(:event) }

  let(:beacon) { FactoryGirl.create(:beacon) }
  let(:zone) { FactoryGirl.create(:zone) }

  it 'validates correctly and saves' do
    expect(event).to be_valid

    expect {
      event.save!
    }.not_to raise_error
  end

  it 'has correct habtm relations with zones and beacons' do
    event.save

    event.beacons << beacon
    event.zones << zone

    event.reload

    expect(event.beacons).to include(beacon)
    expect(event.zones).to include(zone)
  end
end
