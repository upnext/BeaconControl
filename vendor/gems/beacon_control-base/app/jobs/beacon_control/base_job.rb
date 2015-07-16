###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  class BaseJob < ActiveJob::Base
    include BeaconControl::SidekiqLogger

    attr_reader :sidekiq_id

    #
    # Removes job from Sidekiq queue to process before it's picked.
    #
    # ==== Parameters
    #
    # * +job+ - Job to cancel. Could be BeaconControl::BaseJob instance, or string - ID of Sidekiq job.
    #
    def self.cancel(job)
      if job.class == self && DateTime.now.to_i < job.scheduled_at.to_i
        Sidekiq::Status.cancel(job.sidekiq_id)
      elsif job.is_a? String
        Sidekiq::Status.cancel(job)
      else
        false
      end
    end

    around_enqueue do |job, block|
      @sidekiq_id = block.call
    end

    #
    # Wrapper for calling +cancel+ class method on BeaconControl::BaseJob
    #
    def cancel
      self.class.cancel(self)
    end

    rescue_from(Exception) do |e|
      logger.error e
      logger.error e.backtrace.join("\n")
    end
  end
end
