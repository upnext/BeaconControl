###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Beacon

  #
  # Factory for Beacon model.
  #
  class Factory
    NullObject = Naught.build

    def initialize(admin, params, activity = NullObject.new)
      self.admin = admin
      self.beacon = admin.account.beacons.new(params)
      beacon.test_activity = activity
    end

    def build
      beacon.manager = admin if admin.beacon_manager?
      add_to_test_application

      beacon
    end

    def create
      build.tap do |beacon|
        if beacon.valid?
          beacon.save
          beacon.test_activity.save
        end
      end
    end

    private

    attr_accessor :beacon, :admin

    def add_to_test_application
      if test_app = admin.test_application
        beacon.applications_beacons.new(application_id: test_app.id)
        beacon.assign_test_activity(beacon.test_activity)
      end
    end
  end
end
