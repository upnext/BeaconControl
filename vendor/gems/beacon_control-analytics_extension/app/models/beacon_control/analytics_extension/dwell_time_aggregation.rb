###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension

    #
    # Keeps information about dwell time of user in Zone / Beacon range.
    #
    class DwellTimeAggregation < ActiveRecord::Base
      belongs_to :application, class_name: '::Application'

      has_and_belongs_to_many :beacons,
        foreign_key: :ext_analytics_dwell_time_aggregation_id,
        join_table: :ext_analytics_beacons_dwell_time_aggregations

      has_and_belongs_to_many :zones,
        foreign_key: :ext_analytics_dwell_time_aggregation_id,
        join_table: :ext_analytics_dwell_time_aggregations_zones
    end
  end
end
