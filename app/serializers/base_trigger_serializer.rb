###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BaseTriggerSerializer < ApplicationSerializer
  attributes :id, :conditions, :test

  has_one :activity, root: :action

  def conditions
    [
      {
        event_type: object.event_type,
        type: :event_type
      }
    ]
  end
end
