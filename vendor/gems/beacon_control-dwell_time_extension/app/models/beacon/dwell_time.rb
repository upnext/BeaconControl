###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'beacon' unless defined? Beacon

class Beacon
  module DwellTime
    extend ActiveSupport::Concern

    included do
      # Fetches list of beacon's +DwellTime+ action triggers from database for given application.
      #
      # @param [Application] application
      # @return [ActiveRecord::Relation]
      def triggers_for_application(application)
        @triggers ||= triggers.
          joins(:application).
          where(applications: { id: application.id }).
          where(event_type: 'dwell_time')
      end
    end
  end
end
