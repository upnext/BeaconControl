###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    class EventsController < BeaconControl::AdminController
      def dwell_times
        render json: Stats.dwell_time(application_id, limit: limit)
      end

      def action_counts
        render json: Stats.action_count(application_id, limit: limit)
      end

      def unique_users
        render json: Stats.unique_users(application_id, limit: limit)
      end

      private

      def application_id
        params.require(:application_id)
      end

      def limit
        params[:limit] && params[:limit].to_i
      end
    end
  end
end
