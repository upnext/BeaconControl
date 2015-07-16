###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AnalyticsForBeaconsAndZones < ActiveRecord::Migration
  def change
    create_table :ext_analytics_beacons_dwell_time_aggregations do |t|
      t.belongs_to :ext_analytics_dwell_time_aggregation, null: false
      t.belongs_to :beacon,                               null: false
    end

    add_index :ext_analytics_beacons_dwell_time_aggregations,
      [:ext_analytics_dwell_time_aggregation_id, :beacon_id],
      name: :ext_analytics_dta_beacon_idx

    create_table :ext_analytics_dwell_time_aggregations_zones do |t|
      t.belongs_to :ext_analytics_dwell_time_aggregation, null: false
      t.belongs_to :zone,                                 null: false
    end

    add_index :ext_analytics_dwell_time_aggregations_zones,
      [:ext_analytics_dwell_time_aggregation_id, :zone_id],
      name: :ext_analytics_dta_zone_idx

    create_table :ext_analytics_beacons_events, id: false do |t|
      t.belongs_to :ext_analytics_event, null: false
      t.belongs_to :beacon,              null: false
    end

    add_index :ext_analytics_beacons_events,
      [:ext_analytics_event_id, :beacon_id],
      name: :ext_analytics_beacons_events_idx

    create_table :ext_analytics_beacons_zones, id: false do |t|
      t.belongs_to :ext_analytics_event, null: false
      t.belongs_to :zone,                null: false
    end

    add_index :ext_analytics_beacons_zones,
      [:ext_analytics_event_id, :zone_id],
      name: :ext_analytics_beacons_zones_idx
  end
end
