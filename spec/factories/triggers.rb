###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :trigger do
    event_type { 'enter' }
    type { 'BeaconTrigger' }

    factory(:beacon_trigger, class: BeaconTrigger) do
      before(:create) do |trigger|
        trigger.beacons = [FactoryGirl.create(:beacon)]
      end
    end

    factory(:zone_trigger, class: ZoneTrigger) do
      type { 'ZoneTrigger' }
      before(:create) do |trigger|
        trigger.zones = [FactoryGirl.create(:zone)]
      end
    end
  end
end
