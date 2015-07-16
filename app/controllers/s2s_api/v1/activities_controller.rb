###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ActivitiesController < BaseController
      inherit_resources
      load_and_authorize_resource

      self.responder = S2sApiResponder

      actions :index, :create, :update, :destroy

      private

      def collection
        application = Application.find(params[:application_id])
        application.activities.includes(:custom_attributes, :coupon, trigger: [:beacons, :zones])
      end

      def permitted_params
        { activity: ActivityParams.new(params).call }
      end
    end
  end
end
