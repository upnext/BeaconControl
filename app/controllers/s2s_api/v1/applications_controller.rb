###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ApplicationsController < BaseController
      inherit_resources
      load_and_authorize_resource

      self.responder = S2sApiResponder

      actions :index, :update, :destroy

      def create
        factory = Application::Factory.new(current_admin, permitted_params[:application])
        resource = factory.create

        respond_with(resource)
      end

      private

      def begin_of_association_chain
        current_admin.account
      end

      def collection
        super.includes(:doorkeeper_application)
      end

      def permitted_params
        {
          application: params.fetch(:application, {}).permit(*test_app_permitted_params)
        }
      end

      def test_app_permitted_params
        (request.put? || request.patch?) && resource.test ? [] : [:name]
      end
    end
  end
end
