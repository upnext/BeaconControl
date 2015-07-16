###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ZonesController < BaseController
      inherit_resources
      load_and_authorize_resource

      self.responder = S2sApiResponder

      actions :index, :update, :destroy

      def create
        resource = Zone::Factory.new(current_admin, permitted_params[:zone]).create

        respond_with(resource)
      end

      def beacons
        render json: resource.beacons, root: :ranges
      end

      private

      def begin_of_association_chain
        current_admin.account
      end

      def end_of_association_chain
        super.search(search_params)
      end

      def collection
        super.includes(beacons: [:account])
      end

      def permitted_params
        params.permit(zone: [:name, :description, :color] | role_permitted_params | [beacon_ids: []])
      end

      def role_permitted_params
        current_admin.admin? ? [:manager_id] : []
      end

      def search_params
        params.permit(:name)
      end
    end
  end
end
