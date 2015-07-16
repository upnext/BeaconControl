###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class User < ActiveRecord::Base
  belongs_to :application

  has_many :access_tokens, -> { where(scopes: 'user') },
    class_name:  'Doorkeeper::AccessToken',
    foreign_key: 'resource_owner_id',
    dependent:   :destroy

  has_many :mobile_devices, dependent: :destroy

  validates :client_id, uniqueness: { scope: :application_id }, presence: true
end
