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
      before_action :build_test_activity,
                    only: [:create, :update]
      before_action :load_config, only: [:new, :create, :edit, :update]

      self.responder = S2sApiResponder

      rescue_from ::ActionController::ParameterMissing do |error|
        render json: { error: error.message }, status: 422
      end

      rescue_from ::KontaktIo::Error::NotFound do |error|
        render json: { error: error.message }, status: 422
      end

      actions :index, :update, :destroy

      def index
        respond_with(end_of_association_chain, controller: self)
      end

      def info
        wrapped = case resource.vendor
                  when 'Kontakt' then KontaktIoBeacon.new(resource, current_admin)
                  else WrappedBeacon.new(resource, current_admin)
                  end
        respond_with(wrapped)
      end

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
        resource.beacon_config.update_data(current_admin, config_params)
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
        super.where(protocol: 'iBeacon').search(search_params)
      end

      def permitted_params
        params.permit(beacon: [:name, :uuid, :lat, :lng, :floor, :zone_id] | ibeacon_params | eddystone_params | role_permitted_params)
      end

      def ibeacon_params
        [:major, :minor]
      end

      def eddystone_params
        [:url, :instance, :namespace]
      end

      def config_params
        params.fetch(:beacon, {}).fetch(:config, {}).permit(:signal_interval, :transmission_power)
      end

      def role_permitted_params
        current_admin.admin? ? [:manager_id] : []
      end

      def search_params
        params.permit(:name)
      end

      def activity_permitted_params
        if params.fetch(:beacon, {})[:activity]
          ActivityParams.new(
            params.fetch(:beacon, {}).
              deep_merge(activity: {scheme: :custom, trigger_attributes: {type: 'BeaconTrigger'}})
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

      def load_config
        c = resource.beacon_config || resource.build_beacon_config
        c.load_data(current_admin)
      end
    end
  end
end
