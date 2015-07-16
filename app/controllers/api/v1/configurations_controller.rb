###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Api
  module V1
    class ConfigurationsController < BaseController

      #
      # Returns configuration of all beacons that can should cached inside app.
      #
      #   GET /api/v1/configurations
      #
      # ==== Headers
      #
      # * +Authorization+ - Doorkeeper token, provided in headers or in params.
      #
      # ==== Parameters
      #
      # * +access_token+ - Doorkeeper token, provided in headers or in params.
      #
      # ==== Response status
      #
      #   200 OK
      #
      # ==== Response JSON
      #
      #   {
      #     "extensions":{
      #     },
      #     "triggers":[
      #       {
      #         "id":4,
      #         "conditions":[
      #           {
      #             "event_type":"dwell_time",
      #             "type":"event_type"
      #           }
      #         ],
      #         "range_ids": [
      #           1
      #         ],
      #         "actions":[
      #           {
      #             "id":4,
      #             "type":"url",
      #             "name":"test",
      #             "payload":{
      #               "url":"http://test.com"
      #             }
      #           }
      #         ]
      #       },
      #       {
      #         "id":5,
      #         "conditions":[
      #           {
      #             "event_type":"leave",
      #             "type":"event_type"
      #           }
      #         ],
      #         "range_ids": [
      #           1
      #         ],
      #         "actions":[
      #           {
      #             "id":5,
      #             "type":"url",
      #             "name":"Show leave",
      #             "payload":{
      #               "url":"http://merchant.com/goodbye.yml"
      #             }
      #           }
      #         ]
      #       }
      #     ],
      #     "ranges":[
      #       {
      #         "id":1,
      #         "name":"Test",
      #         "proximity_id":"00000000-0000-0000-0000-000000000000+000+000",
      #         "location":{
      #           "lat":null,
      #           "lng":null,
      #           "floor":null
      #         }
      #       }
      #     ],
      #     "zones":[
      #      ],
      #      "ttl":86400
      #   }
      #
      def index
        builder = ConfigurationBuilder.new(application).as_json
        render json: builder.to_json
      end
    end
  end
end
