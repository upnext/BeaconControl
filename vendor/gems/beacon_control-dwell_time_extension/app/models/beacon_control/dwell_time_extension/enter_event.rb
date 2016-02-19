###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module DwellTimeExtension
    class EnterEvent
      include BeaconControl::SidekiqLogger

      def initialize(event, redis = $redis)
        self.event = event
        self.redis = redis
      end

      delegate :beacon, :zone, :application, :mobile_device, to: :event

      #
      # Schedules job to process enter event message in furure by putting it on
      # ActiveJob queue with specific execution timestamp. Also stores created
      # Sidekiq job ID in redis, to allow job cancellation before it's run.
      #
      def call
        triggers.each do |trigger|
          timeout = Time.at(event.timestamp) - Time.now + trigger.dwell_time.minutes

          unique_activity_id = Identifier.new(event, trigger.id).to_s

          if application.rpush_app_for_device(mobile_device).blank?
            logger.info "No RpushApp found for push, skipping"
            return
          end

          job = NotifierJob.after(timeout, {
            action:        trigger.activity,
            application:   application,
            mobile_device: mobile_device,
            identifier:    unique_activity_id
          })

          logger.info "[#{unique_activity_id}] Scheduled notification for \
  mobile_device_id: #{event.mobile_device.id}, proximity_id: #{event.proximity_id}, \
  timeout: #{timeout}, sidekiq_id: #{job.sidekiq_id.to_s}"
          logger.debug "[#{unique_activity_id}] Event: #{event.inspect}"

          redis[unique_activity_id] = job.sidekiq_id.to_s
        end
      end

      private

      attr_accessor :event, :redis

      def triggers
        @triggers ||= (event.with_range? ? 
                       beacon.triggers_for_application(event.application) :
                       zone.triggers_for_application(event.application)
                      )
      end
    end
  end
end
