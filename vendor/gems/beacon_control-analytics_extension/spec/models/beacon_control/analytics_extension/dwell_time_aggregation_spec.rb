###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::AnalyticsExtension::DwellTimeAggregation do
  let(:application) { FactoryGirl.create(:application) }

  let(:dwell_time) { FactoryGirl.build(:dwell_time_aggregation) }

  let(:beacon) { FactoryGirl.create(:beacon) }
  let(:zone) { FactoryGirl.create(:zone) }

  it 'validates correctly and saves' do
    expect(dwell_time).to be_valid

    expect {
      dwell_time.save!
    }.to_not raise_error
  end

  it 'has correct habtm relations with zones and beacons' do
    dwell_time.save

    dwell_time.beacons << beacon
    dwell_time.zones << zone

    dwell_time.reload

    expect(dwell_time.beacons).to include(beacon)
    expect(dwell_time.zones).to include(zone)
  end
end
