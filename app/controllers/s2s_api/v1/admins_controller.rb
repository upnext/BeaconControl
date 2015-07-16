###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class AdminsController < BaseController
      inherit_resources
      load_and_authorize_resource

      self.responder = S2sApiResponder

      actions :index, :create, :update, :destroy

      before_action :build_for_create, only: [:create]

      private

      def begin_of_association_chain
        current_admin.account
      end

      def permitted_params
        {
          admin: params.fetch(:admin, {}).permit([:email, :password, :password_confirmation] | role_permitted_params)
        }.tap{ |param|
          param[:admin][:role] = Admin.roles[param[:admin][:role]] || 'beacon_manager'
        }
      end

      def role_permitted_params
        current_admin.admin? ? [:role] : []
      end

      def build_for_create
        @admin = build_resource
        @admin.password = @admin.password_confirmation = Devise.friendly_token.first(8)
      end
    end
  end
end
