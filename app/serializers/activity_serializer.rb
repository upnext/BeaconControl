###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ActivitySerializer < ApplicationSerializer
  attributes :id, :type, :name, :payload

  has_many :custom_attributes

  def type
    object.scheme
  end
end
