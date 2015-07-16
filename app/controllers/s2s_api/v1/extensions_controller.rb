###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ExtensionsController < BaseController
      before_action :authorize_resources

      def activate
        application.activate_extension(resource)
        render body: false, status: 204
      end

      def deactivate
        application.deactivate_extension(resource)
        render body: false, status: 204
      end

      private

      def application
        @application ||= Application.find(params[:application_id])
      end

      def resource
        @resource ||= current_account.active_extensions.detect{ |ext|
          ext.name == params[:id]
        }
      end

      def authorize_resources
        authorize! :manage, application
        authorize! :manage, resource
      end
    end
  end
end
