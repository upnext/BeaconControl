###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module DwellTimeExtension

    #
    # ActiveJob subclass, configures jobs queuing and implements execution.
    # Used to send APN notifications with delay.
    #
    class NotifierJob < BeaconControl::BaseJob

      #
      # Schedules job execution at given time in future.
      #
      # ==== Parameters
      #
      # * +time+ - Timestamp, time at which job should be executed
      # * +opts+ - Hash, options passed to perform
      #
      def self.after(time, opts)
        scheduled(time).perform_later(opts)
      end

      def self.scheduled(time)
        set(wait: time)
      end

      #
      # Sends APN notification to single user's mobile device.
      #
      # ==== Parameters
      #
      # * +opts+ - Hash, valid keys:
      #   * +:identifier+    - String, unique identifier of ActiveJob instance in redis
      #   * +:action+        - Activity, for which notification will be sent
      #   * +:mobile_device+ - MobileDevice instance, destination of APN
      #   * +:application+   - action's Application
      #
      def perform(opts)
        unique_activity_id = opts.fetch(:identifier)
        action             = opts.fetch(:action)
        application        = opts.fetch(:application)
        mobile_device      = opts.fetch(:mobile_device)

        notification = action.notification_for_device(mobile_device).tap do |n|
          n.app = application.rpush_app_for_device(mobile_device)
          n.save!
        end
        logger.info  "[#{unique_activity_id}] Sending notification: mobile_device_id: #{mobile_device.id}, action_id: #{action.id}, app_id: #{application.id}"
        logger.debug "[#{unique_activity_id}] Notification details: #{notification.inspect}"
      ensure
        $redis.delete(unique_activity_id)
      end
    end
  end
end
