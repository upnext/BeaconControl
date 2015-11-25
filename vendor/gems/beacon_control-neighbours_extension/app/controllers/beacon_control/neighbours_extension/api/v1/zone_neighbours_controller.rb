module BeaconControl
  module NeighboursExtension
    module Api
      module V1
        class ZoneNeighboursController < ::BeaconControl::Api::V1::BaseController
          rescue_from ::ActiveRecord::RecordNotFound do |error|
            render json: error, status: :not_found
          end

          def create
            neighbour = ::BeaconControl::NeighboursExtension::CreateNeighbourService.new(current_zone).create(message)
            render json: neighbour, status: (neighbour.persisted? ? :created : :unprocessable_entity)
          end

          def destroy
            ::BeaconControl::NeighboursExtension::DestroyNeighbourService.new(current_zone).destroy(message)
            render :nothing, status: :no_content
          end

          def show
            render json: ::BeaconControl::NeighboursExtension::LoadNeighbourService.
                     new(current_zone).
                     json_for_all.to_json
          end

          private

          def current_zone
            @current_zone ||= current_admin.account.zones.find(params[:id])
          end
        end
      end
    end
  end
end
