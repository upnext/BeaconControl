###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

FactoryGirl.define do
  factory :admin do
    sequence(:email)      { |n| "admin-#{n}@example.com" }
    password              'secret123'
    password_confirmation 'secret123'
    role                  'admin'
    confirmed_at          { Time.now }
    account               { FactoryGirl.create(:account) }
  end
end
