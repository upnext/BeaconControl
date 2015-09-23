###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    require "s2s_api_responder"

    class BaseController < ApplicationController
      before_action :doorkeeper_authorize!

      rescue_from StandardError do |e|
        Rails.logger.info e.message
        Rails.logger.debug e

        render json: {}, status: 500
      end

      rescue_from ActiveRecord::RecordNotFound do |e|
        Rails.logger.info e.message

        render json: {}, status: 404
      end

      rescue_from CanCan::AccessDenied do |e|
        Rails.logger.info e.message

        render json: {}, status: 403
      end

      respond_to :json

      private

      def current_admin
        @current_admin ||= begin
          admin = Admin.find(doorkeeper_token.resource_owner_id)
          admin ? AdminDecorator.new(admin) : nil
        end
      end

      def current_account
        @current_account ||= current_admin.account
      end

      def doorkeeper_authorize!
        super(:s2s_api)
      end

      def raw_authorize!
        unless Doorkeeper::Application.find_by(uid: params[:client_id], secret: params[:client_secret])
          render json: {}, status: 403
        end
      end

      def collection_action?
        action_name == 'index'
      end
    end
  end
end
