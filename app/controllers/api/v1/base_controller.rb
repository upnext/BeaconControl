###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Api
  module V1
    class BaseController < ApplicationController
      before_action -> { doorkeeper_authorize! :api }

      private

      def application
        @application ||= doorkeeper_token.application.owner
      end

      def current_user
        @current_user ||= current_device.user
      end

      def current_device
        @current_device ||= MobileDevice.find(doorkeeper_token.resource_owner_id)
      end
    end
  end
end
