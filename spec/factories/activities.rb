###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :activity do |activity|
    sequence(:name) { |n| "Activity #{n}" }

    factory :url_activity do
      scheme 'url'
    end

    factory :coupon_activity do
      scheme 'coupon'
      coupon { FactoryGirl.create(:coupon) }
    end

    ignore do
      application nil
    end

    trigger { FactoryGirl.create(:beacon_trigger, application: application) }
  end
end
