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

  include BeaconAllowedParams # MUST be after inherit_resources and load_and_authorize_resource

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

    render json: @beacons,
           each_serializer: S2sApi::V1::BeaconSerializer
  end

  def create
    @beacon = create_beacon
    @beacon.persisted? ? redirect_to_beacons : render_new
  end

  def update
    resource.update_test_activity(activity_permitted_params)
    resource.beacon_config.update_data(current_admin, config_params)

    update! do |format|
      format.json { render json: S2sApi::V1::BeaconSerializer.new(resource) }
      format.html { redirect_to_beacons } if resource.errors.empty?
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

  def redirect_to_beacons
    redirect_to beacons_url
  end

  def render_new
    render :new
  end

  def create_beacon
    Beacon::Factory.new(
      current_admin,
      permitted_params[:beacon],
      Activity.new(activity_permitted_params)
    ).create
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
