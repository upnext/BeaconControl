###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ZonesController < AdminController
  inherit_resources
  load_and_authorize_resource

  actions :index, :new, :edit, :update, :destroy

  before_filter -> { @beacons = current_admin.account.beacons.unassigned.accessible_by(current_ability) },
    only: [:new, :create]
  before_filter -> { @beacons = current_admin.account.beacons.unassigned.accessible_by(current_ability) + resource.beacons },
    only: [:edit, :update]

  def index
    @zones = collection.
      search(search_params).
      order("#{params[:sort]} #{params[:direction]} ")
    index!
  end

  def create
    @zone = Zone::Factory.new(current_admin, permitted_params[:zone]).create

    if @zone.persisted?
      redirect_to zones_url
    else
      render :new
    end
  end

  private

  def search_params
    params.permit(:name)
  end

  def permitted_params
    {
      zone: params.fetch(:zone, {}).permit([:name, :description, :color, :move_beacons] | role_permitted_params, beacon_ids: [])
    }
  end

  def role_permitted_params
    current_admin.admin? ? [:manager_id] : []
  end

  def begin_of_association_chain
    current_admin.account
  end
end
