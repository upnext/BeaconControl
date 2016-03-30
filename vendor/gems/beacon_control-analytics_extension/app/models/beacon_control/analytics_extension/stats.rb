###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    module Stats
      DEFAULT_LIMIT = 14

      #
      # Calculates summary user's dwell time for each day in range (Today - limit.days .. Today).
      #
      # ==== Parameters
      #
      # * +application_id+ - Integer, ID of Application to run query against
      # * +options+        - Hash, valid keys:
      #   * +:limit+       - Integer, number of days to calculate statistics back from today
      #
      def self.dwell_time(application_id, options = {})
        days = options[:limit] || DEFAULT_LIMIT

        convert_to_range(
          days,
          BeaconControl::AnalyticsExtension::DwellTimeAggregation.
            where(application_id: application_id).
            where("timestamp <= ?", Time.now).
            order('date desc').
            limit(days).
            group(:date).
            sum(:dwell_time)
        )
      end

      #
      # Calculates number of user's actions for each day in range (Today - limit.days .. Today).
      #
      # ==== Parameters
      #
      # * +application_id+ - Integer, ID of Application to run query against
      # * +options+        - Hash, valid keys:
      #   * +:limit+       - Integer, number of days to calculate statistics back from today
      #
      def self.action_count(application_id, options = {})
        days = options[:limit] || DEFAULT_LIMIT

        convert_to_range(
          days,
          BeaconControl::AnalyticsExtension::Event.
            where(application_id: application_id).
            where("timestamp <= ?", Time.now).
            order('date_timestamp desc').
            limit(days).
            group('DATE(timestamp)').
            count(:action_id)
        )
      end

      #
      # Calculates number of unique users which generated any events, for each day in range (Today - limit.days .. Today).
      #
      # ==== Parameters
      #
      # * +application_id+ - Integer, ID of Application to run query against
      # * +options+        - Hash, valid keys:
      #   * +:limit+       - Integer, number of days to calculate statistics back from today
      #
      def self.unique_users(application_id, options = {})
        days = options[:limit] || DEFAULT_LIMIT

        convert_to_range(
          days,
          BeaconControl::AnalyticsExtension::Event.
            where(application_id: application_id).
            where("timestamp <= ?", Time.now).
            order('date_timestamp desc').
            limit(days).
            group('DATE(timestamp)').
            count('DISTINCT user_id')
        )
      end

      private

      #
      # Creates hash with
      # keys   => days in range (Today - limit.days .. Today)
      # values => statistic for given day from +data+ parameter
      #
      # ==== Parameters
      #
      # * +limit+ - Integer, number of days to create keys in response back from today
      # * +data+  - Hash, requested statistics in format date => number
      #
      # ==== Example
      #
      #   convert_to_range(3, {Date.today => 1}) #=> {Sat, 21 Mar 2015=>0, Sun, 22 Mar 2015=>0, Mon, 23 Mar 2015=>0, Tue, 24 Mar 2015=>1}
      #
      def self.convert_to_range(limit, data) # :doc:
        (limit.days.ago.to_date .. Date.today).each_with_object({}) do |day, hash|
          hash[day] = data[day].to_i
        end
      end
    end
  end
end
