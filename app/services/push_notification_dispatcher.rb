###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class PushNotificationDispatcher
  def initialize(device, notification)
    self.device       = device
    self.notification = notification
  end

  private

  attr_accessor :device, :notification
end
