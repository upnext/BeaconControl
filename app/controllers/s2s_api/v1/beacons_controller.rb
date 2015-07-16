###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class BeaconsController < BaseController
      inherit_resources
      load_and_authorize_resource
      before_action :build_test_activity, only: [:create, :update]

      self.responder = S2sApiResponder

      actions :index, :update, :destroy

      def create
        activity = Activity.new(activity_permitted_params)
        resource = Beacon::Factory.new(
          current_admin,
          permitted_params[:beacon],
          activity
        ).create

        respond_with(resource)
      end

      def update
        resource.update_test_activity(activity_permitted_params)
        update!
      end

      def batch_destroy
        @beacons = collection.where(id: params[:ids])
        @beacons.delete_all

        respond_with(@beacons)
      end

      private

      def begin_of_association_chain
        current_admin.account
      end

      def end_of_association_chain
        super.search(search_params)
      end

      def permitted_params
        params.permit(beacon: [:name, :uuid, :major, :minor, :lat, :lng, :floor, :zone_id] | role_permitted_params)
      end

      def role_permitted_params
        current_admin.admin? ? [:manager_id] : []
      end

      def search_params
        params.permit(:name)
      end

      def activity_permitted_params
        if params.fetch(:beacon, {})[:activity]
          ActivityParams.new(params.fetch(:beacon, {})
            .deep_merge(activity: {scheme: :custom, trigger_attributes: {type: 'BeaconTrigger'}})
          ).call 
        else
          {}
        end
      end

      def default_serializer_options
        { root: collection_action? ? :ranges : :range }
      end

      def build_test_activity
        resource.build_test_activity
      end
    end
  end
end
