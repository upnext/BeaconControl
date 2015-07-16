###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :beacon do
    sequence(:name) { |n| "Beacon #{n}" }

    account

    uuid { SecureRandom.uuid.upcase }

    major { rand(10).to_s }
    minor { rand(10).to_s }
  end
end
