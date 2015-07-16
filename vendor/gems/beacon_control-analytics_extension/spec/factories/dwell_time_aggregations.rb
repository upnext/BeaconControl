###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :dwell_time_aggregation, class: BeaconControl::AnalyticsExtension::DwellTimeAggregation do
    application
    proximity_id "B9407F30-F5F8-466E-AFF9-25556B57FE6D+10000+123"
    user_id      "sdfgas"
    date         { Date.today }
    timestamp    { Time.now }
    dwell_time   { 60 }
  end
end
