###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ApplicationSettingsController < BaseController

      def index
        factory.build

        respond_with(application.application_settings, each_serializer: ApplicationSettingSerializer)
      end

      def update
        factory.update(permitted_params)

        if application.valid?
          render body: false, status: 204
        else
          render json: application.application_settings, each_serializer: ApplicationSettingSerializer, status: 422
        end
      end

      private

      def application
        @application ||= Application
          .accessible_by(current_ability)
          .find(params[:application_id])
      end

      def factory
        ApplicationSetting::Factory.new(application)
      end

      def permitted_params
        params.permit(application_settings: [:extension_name, :type, :key, :value])
      end
    end
  end
end
