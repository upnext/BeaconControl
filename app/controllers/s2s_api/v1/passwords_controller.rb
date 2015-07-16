###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class PasswordsController < BaseController
      skip_before_action :doorkeeper_authorize!
      before_action :raw_authorize!

      self.responder = S2sApiResponder

      def create
        resource = Admin.send_reset_password_instructions(permitted_params)
        respond_with(resource, location: '/')
      end

      def update
        resource = Admin.reset_password_by_token(permitted_params)
        resource.errors.add(:password_confirmation, :mismatch) unless resource.password == resource.password_confirmation
        respond_with(resource, location: '/')
      end

      private

      def permitted_params
        params.fetch(:admin, {}).permit(:email, :password, :password_confirmation, :reset_password_token)
      end
    end
  end
end
