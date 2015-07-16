###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationsBeaconsController < AdminController
  def create
    ab = ApplicationsBeacon.create(permitted_params)
    render json: ab.to_json
  end

  def destroy
    ab = ApplicationsBeacon.find_by(application_id: params[:application_id], beacon_id: params[:beacon_id])
    ab.destroy
    render json: ab.to_json, status: ab.persisted? ? :unprocessable_entity : :ok
  end

  private

  def permitted_params
    params.permit(:application_id, :beacon_id)
  end
end
