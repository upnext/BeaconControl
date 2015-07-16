###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CreateDwellTimeAggregation < ActiveRecord::Migration
  def change
    create_table :ext_analytics_dwell_time_aggregations do |t|
      t.belongs_to :application,  null: false, index: true
      t.string     :proximity_id, null: false, index: true
      t.string     :user_id,                   index: true
      t.date       :date,         null: false, index: true
      t.datetime   :timestamp,    null: false, index: true

      t.integer    :dwell_time,   null: false, default: 0

      t.timestamps null: false
    end
  end
end
