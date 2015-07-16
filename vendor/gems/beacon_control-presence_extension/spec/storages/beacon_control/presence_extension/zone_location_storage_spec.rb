###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::PresenceExtension::ZoneLocationStorage do
  it 'stores events' do
    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3145.67)
    ).enter

    expect(described_class.users_in_zones(['100'])['100']).to include('foo')
  end

  it 'store one user in many zones' do
    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3145.67)
    ).enter
    described_class.new(
      double(zone_id: 101, client_id: 'foo', timestamp: 3145.67)
    ).enter

    expect(described_class.users_in_zones(['100'])['100']).to include('foo')
    expect(described_class.users_in_zones(['101'])['101']).to include('foo')
  end

  it 'deletes presence', failure: true do
    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3145.67)
    ).enter

    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3148.67)
    ).leave

    expect(described_class.users_in_zones(['100'])['100']).not_to include('foo')
  end

  it 'leaves presence if leave timestamp is earlier' do
    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3145.67)
    ).enter

    described_class.new(
      double(zone_id: 100, client_id: 'foo', timestamp: 3142.67)
    ).leave

    expect(described_class.users_in_zones(['100'])['100']).to include('foo')
  end
end
