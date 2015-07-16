###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ActivitiesController < AdminController
  helper_method Activity::SCHEMES

  helper_method :campaigns

  before_action :application

  Activity::SCHEMES.each do |scheme|
    define_method(scheme) do
      activities.where(scheme: scheme).decorate
    end
  end

  def new
    @activity = activities.new(scheme: scheme_param).decorate
    @activity.build_trigger(type: "BeaconTrigger")
    @activity.build_coupon
  end

  def edit
    @activity = activities.find(params[:id]).decorate
  end

  def create
    @activity = activities.new(permitted_params).decorate

    if @activity.save
      redirect_to application_activities_path(application)
    else
      render :new
    end
  end

  def update
    @activity = activities.find(params[:id])

    if @activity.update_attributes(permitted_params)
      redirect_to application_activities_path(application)
    else
      render :edit
    end
  end

  def destroy
    activities.where(id: params[:id]).destroy_all

    render :index
  end

  private

  def application
    @application ||= current_admin.applications.find(params[:application_id]).decorate
  end

  def activities
    application.activities.includes(trigger: :beacons).order(:id)
  end

  def permitted_params
    ActivityParams.new(params).call
  end

  def scheme_param
    params.require(:event_type)
  end
end
