###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class PresencesController < BeaconControl::AdminController
      inherit_resources

      def show
        @application = begin_of_association_chain.applications.
          find(params[:application_id]).
          decorate
        @beacons_and_zones = begin_of_association_chain.
          account.
          beacons_and_zones(
            @application.id,
            query_params
          )
        render 'show'
      end

      protected

      def query_params
        {
          name: sorted_params[:name],
          sort: sorted_params[:sort] || sorted_params[:column],
          direction: sorted_params[:direction]
        }
      end

      def sorted_params
        params.fetch(:sorted, {}).permit(:name, :sort, :direction, :column)
      end

      def begin_of_association_chain
        current_admin
      end
    end
  end
end
