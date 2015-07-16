###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Zone

  #
  # Factory for Zone model.
  #
  class Factory
    def initialize(admin, params)
      @params = params
      @admin = admin
      @zone = admin.account.zones.new(zone_params)
    end

    def build
      zone.manager = admin if admin.beacon_manager?
      add_to_test_application

      zone
    end

    def create
      build.tap do |zone|
        zone.save if zone.valid?
      end
    end

    private

    attr_accessor :zone, :admin, :params

    def add_to_test_application
      zone.applications_zones.new(application_id: test_app.id) if test_app
    end

    def test_app
      Application.where(account_id: zone.account_id, test: true).first
    end

    def zone_params
      p = (params || {}).clone
      p[:beacon_ids] = p[:beacon_ids].present? ? p[:beacon_ids].reject(&:blank?) : []
      p
    end
  end
end
