###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Brand < ActiveRecord::Base
  has_one :doorkeeper_application,
    class_name: 'Doorkeeper::Application',
    as: :owner

  has_many :accounts
  has_many :admins, through: :accounts

  validates :name, presence: true
end
