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
    PARAMS_ORDER = %w[ vendor protocol vendor_uid proximity uuid major minor namespace instance url name ]

    NullObject = Naught.build

    # @param [Admin] admin
    # @param [Hash] params
    # @param [Application|NullObject] activity
    def initialize(admin, params, activity = NullObject.new)
      @admin = admin
      @beacon = admin.account.beacons.new(self.class.sorted_params(params))
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

    def self.sorted_params(params)
      (params || {}).sort do |(a,_), (b,_)|
        a, b = a.to_s, b.to_s
        if PARAMS_ORDER.include?(a) && PARAMS_ORDER.include?(b)
          PARAMS_ORDER.index(a) - PARAMS_ORDER.index(b)
        elsif PARAMS_ORDER.include?(a)
          -PARAMS_ORDER.index(a)
        elsif PARAMS_ORDER.include?(b)
          PARAMS_ORDER.index(b)
        else
          a <=> b
        end
      end.reduce({}) do |memo, (k, v)|
        if k == 'proximity'
          memo['uuid'] = v
        else
          memo[k] = v
        end
        memo
      end.with_indifferent_access
    end
  end
end
