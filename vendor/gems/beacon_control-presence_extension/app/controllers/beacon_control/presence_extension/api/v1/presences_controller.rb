###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    module Api
      module V1
        class PresencesController < BeaconControl::Api::V1::BaseController

          #
          # Returns list of Beacon / Zone presences.
          #
          #   GET /api/v1/presence
          #
          # ==== Headers
          #
          # * +Authorization+ - Doorkeeper token, provided in headers or in params.
          #
          # ==== Parameters
          #
          # * +ranges+ - Array, list of Beacons IDs to filter results by.
          # * +zones+  - Array, list of Zones IDs to filter results by.
          #
          # ==== Response status
          #
          #   200 OK
          #
          # ==== Response JSON
          #
          # ===== Example
          #   GET /api/v1/presence
          # =====
          #   {
          #     "ranges":{
          #       "1":[
          #         "testclient"
          #       ],
          #       "3": [
          #         "foobar"
          #       ]
          #     },
          #     "zones":{
          #       "2": [
          #         "test"
          #      ]
          #     }
          #   }
          #
          # ===== Example
          #   GET /api/v1/presence?ranges[]=1&ranges[]=2&zones[]=1
          # =====
          #   {
          #     "ranges":{
          #       "1":[
          #         "testclient"
          #       ]
          #     },
          #     "zones":{
          #     }
          #   }
          #
          def show
            users = BeaconControl::PresenceExtension::Storage.get_status(application, presence_params).as_json

            render json: users.to_json, status: :ok
          end

          private

          def presence_params
            params.slice(:ranges, :zones)
          end
       end
      end
    end
  end
end
