###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Api
  module V1
    class EventsController < BaseController

      rescue_from JSON::ParserError do
        render json: { error: 'data json malformed' }, status: :unprocessable_entity
      end
      #
      # Processes events by all active extension's workers.
      #
      #   POST /api/v1/events
      #
      # ==== Parameters
      #
      # * +events+         - Array of events data to process, containing:
      #   * +event_type+
      #   * +proximity_id+
      #   * +action_id+
      # * +access_token+   - Doorkeeper token, provided in headers or in params.
      #
      # ==== Request JSON
      #
      # ===== Example
      #   {
      #    "events": [
      #       {
      #         "event_type": "enter",
      #         "proximity_id": "B9407F30-F5F8-466E-AFF9-25556B57FE6D+10000+123",
      #         "action_id": 1
      #       }
      #     ],
      #     "access_token": "3f869446e859ec87d38bcae12e83d566af22ea4dc1ccaa6f74364a2f1969ebd8"
      #   }
      #
      # ===== Example
      #   {
      #     "events": [
      #       {
      #         "event_type": "leave",
      #         "zone_id": 1,
      #         "action_id": 1
      #       }
      #     ]
      #   }
      #
      # ==== Response status
      #
      #   200 OK
      #
      def create
        EventProcessor.process(message_params)

        head :ok
      end

      private

      def message_params
        {
          events:        event_params,
          application:   application,
          user:          current_user,
          mobile_device: current_device,
        }
      end

      def event_params
        @events ||= params.require(:events)
      end
    end
  end
end
