###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationsController < AdminController
  inherit_resources
  load_and_authorize_resource

  before_action :build_rpush_apps, only: [
    :edit, :set_apns_production_cert, :set_apns_sandbox_cert
  ]
  before_action :build_app_settings, only: [
    :edit
  ]

  def create
    application = Application::Factory.new(current_admin, permitted_params)

    app = application.create
    if app.persisted?
      redirect_to application_activities_path(app)
    else
      redirect_to :back
    end
  end

  def update
    @application.update_attributes(permitted_params)

    redirect_to :back
  end

  def destroy
    @application.destroy
    redirect_to :back
  end

  def set_apns_sandbox_cert
    rpush_app = RpushApnsApp.new(
      cert_permitted_params[:apns_app_sandbox_attributes].merge(
        environment: 'sandbox',
        application: @application
      )
    ).app

    if rpush_app.valid?
      @application.apns_app_sandbox = rpush_app
      @application.save
    end

    redirect_to edit_application_path(@application)
  end

  def set_apns_production_cert
    rpush_app = RpushApnsApp.new(
      cert_permitted_params[:apns_app_production_attributes].merge(
        environment: 'production',
        application: @application
      )
    ).app

    if rpush_app.valid?
      @application.apns_app_production = rpush_app
      @application.save
    end

    redirect_to edit_application_path(@application)
  end

  private

  def permitted_params
    params.require(:application).permit(
      *test_app_permitted_params,
      application_settings_attributes: [:id, :extension_name, :type, :key, :value]
    )
  end

  def test_app_permitted_params
    application.test ? [] : [:name]
  end

  def cert_permitted_params
    params.require(:application).permit(
      apns_app_sandbox_attributes: [:id, :passphrase, :cert_p12],
      apns_app_production_attributes: [:id, :passphrase, :cert_p12]
    )
  end

  def begin_of_association_chain
    current_admin
  end

  def resource
    super.decorate
  end

  def collection
    @applications = super.decorate
  end

  def application
    @application ||= Application.new
  end
  helper_method :application

  def build_rpush_apps
    @application.apns_app_sandbox    || @application.build_apns_app_sandbox
    @application.apns_app_production || @application.build_apns_app_production
  end

  def build_app_settings
    ApplicationSetting::Factory.new(@application).build
  end
end
