###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class PushNotificationDispatcher
  class Apns
    def initialize(device_token, notification)
      self.device_token = device_token
      self.notification = notification
    end

    private

    attr_accessor :device_token, :notification
  end
end
