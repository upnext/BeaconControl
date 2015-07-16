###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class RegistrationsController < BaseController
      skip_before_action :doorkeeper_authorize!
      before_action :raw_authorize!
      before_action :check_registerable

      extendable :params, as: :permitted_params
      extend_params :permitted_params,
                    fetch: :admin,
                    permit: [:email, :password]

      self.responder = S2sApiResponder

      def create
        admin = Admin::Factory.new(permitted_params.merge(role: :admin)).create
        respond_with(admin)
      end

      private

      def check_registerable
        render json: {}, status: :forbidden unless AppConfig.registerable
      end
    end
  end
end
