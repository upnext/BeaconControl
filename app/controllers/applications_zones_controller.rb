###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationsZonesController < AdminController
  def create
    az = ApplicationsZone.create(permitted_params)
    render json: az.id
  end

  def destroy
    az = ApplicationsZone.find_by(application_id: params[:application_id], zone_id: params[:zone_id])
    az.destroy
    render json: az.to_json, status: az.persisted? ? :unprocessable_entity : :ok
  end

  private

  def permitted_params
    params.permit(:application_id, :zone_id)
  end
end
