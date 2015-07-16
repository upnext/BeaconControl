###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    class TimeRange
      def initialize(start_time, end_time)
        self.start_time = start_time
        self.end_time = end_time
      end

      #
      # For given start & end timestamps, creates an array of days between them, with
      # +start_time+ and +end_time+ included as first/last element.
      #
      # ==== Example
      #
      #   start_time      #=> 2015-03-24 00:00:00
      #   end_time        #=> 2015-03-25 23:59:59
      #
      #   split_to_days() #=> [1427155200, 1427238000, 1427324400, 1427327999] # which is
      #                   #   [2015-03-24 00:00:00, 2015-03-24 23:00:00, 2015-03-25 23:00:00, 2015-03-25 23:59:59]
      #
      def split_to_days
        dwell_time = end_time - start_time
        date_range = [start_time.to_i, end_time.to_i]

        if start_time.day != end_time.day
          beginning_of_day = Time.at(start_time.to_i).beginning_of_day + 1.day
          date_range = [start_time.to_i] + (
            beginning_of_day.to_i..end_time.to_i).step(1.day).to_a
          date_range += [end_time.to_i] if date_range.last != end_time.to_i
        end

        date_range
      end

      attr_accessor :start_time, :end_time
    end
  end
end
