###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Activity
  class Notification

    #
    # Null object for consuming not supported OSes. Will accept any method and not
    # raise exteptions.
    #
    Null = Naught.build do |config|
      config.black_hole
    end

    def initialize(device, action)
      self.device = device
      self.action = action
    end

    delegate :os, :push_token, to: :device
    delegate :name, :id, to: :action

    #
    # Builds Rpush notification for specific mobile OS.
    #
    def build
      case os
      when 'ios'     then ios_notification
      when 'android' then android_notification
      else Null.new
      end
    end

    private

    attr_accessor :device, :action

    def android_notification
      Rpush::Gcm::Notification.new(
        registration_ids: [ push_token ],
        data: {
          alert:     name,
          action_id: id
        }
      )
    end

    def ios_notification
      Rpush::Apns::Notification.new(
        device_token: push_token,
        alert:        name,
        data: {
          action_id: id
        }
      )
    end
  end
end
