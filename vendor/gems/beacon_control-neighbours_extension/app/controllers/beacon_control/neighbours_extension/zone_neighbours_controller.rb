###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

module BeaconControl
  module NeighboursExtension
    class ZoneNeighboursController < ::BeaconControl::AdminController
      def create
        neighbour = ::BeaconControl::NeighboursExtension::CreateNeighbourService.new(current_zone).create(params)
        render_sync(neighbour.persisted? ? :created : :unprocessable_entity)
      end

      def destroy
        count = ::BeaconControl::NeighboursExtension::DestroyNeighbourService.new(current_zone).destroy(params)
        render_sync(count > 0 ? :ok : :unprocessable_entity)
      end

      def sync
        render_sync
      end

      private

      def render_sync(status = :ok)
        render json: ::BeaconControl::NeighboursExtension::LoadNeighbourService.
                 new(current_zone).
                 json_for_all.to_json,
               status: status
      end

      def begin_of_association_chain
        current_admin
      end

      def current_zone
        @current_zone ||= application.zones.find(params[:zone_id])
      end

      def application
        @application ||= begin_of_association_chain.
          applications.
          find(params[:application_id])
      end
    end
  end
end
