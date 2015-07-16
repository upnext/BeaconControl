###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :account do
    sequence(:name) { |n| "Activity #{n}" }
    brand { Brand.first || Brand.create(name: "BeaconOS") }
  end
end
