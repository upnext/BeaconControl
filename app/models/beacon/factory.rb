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

    # @param [Admin] admin
    # @param [Hash] params
    # @param [Application|NullObject] activity
    def initialize(admin, params, activity = NullObject.new)
      @admin = admin
      @beacon = admin.account.beacons.new(params)
      beacon.test_activity = activity
    end

    # @return [Beacon]
    def build
      @beacon.manager = @admin if @admin.beacon_manager?
      add_to_test_application

      @beacon
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
      return unless @admin.test_application
      @beacon.applications_beacons.new(application_id: @admin.test_application.id)
      @beacon.assign_test_activity(@beacon.test_activity)
    end
  end
end
