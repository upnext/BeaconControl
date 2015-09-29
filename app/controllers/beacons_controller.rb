###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BeaconsController < AdminController
  inherit_resources
  load_and_authorize_resource
  custom_actions collection: :batch_update
  before_action :load_and_authorize_zones
  before_action :build_test_activity, only: [:new, :create, :edit, :update]
  before_action :load_config, only: [:new, :create, :edit, :update]

  has_scope :sorted, using: [:column, :direction], type: :hash, default: {
    column: 'zones.name',
    direction: 'asc'
  }
  has_scope :with_beacon_or_zone_name, as: :beacon_name

  def new
    resource.uuid ||= current_admin.default_beacon_uuid
    @beacon = resource.decorate
    new!
  end

  def index
    @beacons = BeaconDecorator.decorate_collection apply_scopes(collection).all
    index!
  end

  def search
    @beacons = collection.with_location.search(search_params)

    render json: @beacons, each_serializer: S2sApi::V1::BeaconSerializer
  end

  def create
    activity = Activity.new(activity_permitted_params)
    @beacon = Beacon::Factory.new(
      current_admin, permitted_params[:beacon], activity
    ).create

    if @beacon.persisted?
      redirect_to beacons_url
    else
      render :new
    end
  end

  def update
    resource.update_test_activity(activity_permitted_params)

    update! do |format|
      format.json { render json: S2sApi::V1::BeaconSerializer.new(resource) }
      format.html { redirect_to beacons_url } if resource.errors.empty?
    end
  end

  def destroy
    destroy! do |format|
      format.json { render json: {}, status: :ok }
      format.html { redirect_to beacons_url }
    end
  end

  def batch_update
    collection.where(id: params[:beacon_ids]).
      reorder('').
      update_all(permitted_params[:beacon])
    redirect_to beacons_url
  end

  def batch_delete
    collection.destroy_all(id: params[:beacon_ids])
    redirect_to beacons_url
  end

  private

  def search_params
    params.permit(:name, :sort, :direction, :floor, zone_id: [])
  end

  def permitted_params
    {
      beacon: params.fetch(:beacon, {}).permit(
        default_params | role_permitted_params | protocol_params
      )
    }
  end

  def default_params
    [:name, :location, :lat, :lng, :floor, :zone_id, :protocol, :vendor]
  end

  def i_beacon_params
    [:uuid, :major, :minor]
  end

  def eddystone_params
    [:namespace, :instance, :url]
  end

  def protocol_params
    i_beacon_params | eddystone_params
  end

  def activity_permitted_params
    ActivityParams.new(
      params[:beacon].deep_merge(
        activity: {
          scheme: :custom,
          trigger_attributes: {
            type: 'BeaconTrigger'
          }
        }
      )
    ).call
  end

  def role_permitted_params
    current_admin.admin? ? [:manager_id] : []
  end

  def begin_of_association_chain
    current_admin.account
  end

  def end_of_association_chain
    super.includes(:zone).references(:zone)
  end

  def load_and_authorize_zones
    @zones = Zone.accessible_by(current_ability)
  end

  def build_test_activity
    resource.build_test_activity
  end

  def load_config
    c = resource.beacon_config || resource.build_beacon_config
    c.load_data(current_admin)
  end
end
