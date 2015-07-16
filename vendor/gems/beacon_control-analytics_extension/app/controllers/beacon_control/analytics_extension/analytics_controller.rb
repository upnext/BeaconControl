###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module AnalyticsExtension
    class AnalyticsController < BeaconControl::AdminController
      inherit_resources

      def show
        @application = begin_of_association_chain.applications.find(params[:application_id]).decorate
      end

      def begin_of_association_chain
        current_admin
      end
    end
  end
end
