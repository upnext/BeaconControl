###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module EventProcessor
  class EventDispatcher
    def initialize(params)
      self.event      = params.fetch(:event)
      self.extensions = params.fetch(:extensions)
    end

    #
    # Publishes single event to all enabled extensions.
    #
    def dispatch
      if event.event_type.present?
        extensions.each do |extension|
          logger.info "Processing extension: #{extension.name}"

          dispatch_event(extension)
        end
      else
        logger.info "Event is invalid (not publishing it)"
      end
    end

    private

    attr_accessor :event, :activity, :beacon, :extensions

    def dispatch_event(extension)
      extension.publish(event)
    end

    def logger
      Sidekiq.logger
    end
  end
end
