# Beacon configuration such as:
# * signal interval
# * transmission power
#
# @author Adrian Wozniak
# @since 29.09.2015
module S2sApi
  module V1
    class BeaconConfigsController < BaseController
      inherit_resources
      authorize_resource

      self.responder = S2sApiResponder

      rescue_from ActionController::ParameterMissing do |error|
        render json: { message: error.message },
               status: :unprocessable_entity,
               root: :error
      end

      # [GET] /beacons/:beacon_id/config
      def show
        resource.load_data(current_admin)
        render json: resource,
               status: :ok,
               root: :config
      end

      # Save beacon configuration.
      # [PUT] /beacons/:beacon_id/config
      # @example
      #   { beacon: { config: Hash } } # params
      def update
        resource.update_data(current_admin, config_params) if config_params.present?
        if resource.save
          render json: resource,
                 status: :ok,
                 root: :config
        else
          render json: resource,
                 status: :unprocessable_entity,
                 root: :config
        end
      end

      # Confirm beacon was already updated.
      # [PUT] /beacons/:beacon_id/beacon_updated
      def confirm
        resource.update_attributes(
          beacon_updated_at: Time.now,
          updated_at: Time.now
        )
        render json: resource,
               root: :config,
               status: :ok
      end

      private def resource
        @resource ||= BeaconConfig.where(beacon_id: params[:id]).first_or_create!(
          beacon_id: params[:id],
          data: {}
        )
      end

      private def config_params
        beacon_params.fetch(:config, {}).permit!.to_h
      end

      private def beacon_params
        params.fetch(:beacon, {})
      end
    end
  end
end
