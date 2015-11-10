module BeaconAllowedParams
  extend ActiveSupport::Concern
  included do
    rescue_from ActiveModel::ForbiddenAttributesError do |error|
      render json: { error: error.message, stack: error.backtrace },
             status: 500
    end if Rails.env.development?
  end

  def search_params
    params.permit(:name, :sort, :direction, :floor, zone_id: [])
  end

  def permitted_params
    {
      beacon: Beacon::Factory.sorted_params(params.fetch(:beacon, {}).permit(
        default_params | role_permitted_params | protocol_params
      ))
    }
  end

  def default_params
    [:name, :location, :lat, :lng, :floor, :zone_id, :protocol, :vendor, :vendor_uid]
  end

  def i_beacon_params
    [:uuid, :major, :minor, :proximity]
  end

  def eddystone_params
    [:namespace, :instance, :url]
  end

  def protocol_params
    i_beacon_params | eddystone_params
  end

  def activity_permitted_params
    if fetched_beacon_params.key?(:activity)
      ActivityParams.new(
        fetched_beacon_params.deep_merge(
          activity: {
            scheme: :custom,
            trigger_attributes: {
              type: 'BeaconTrigger'
            }
          }
        )
      ).call
    else
      {}
    end
  end

  def config_params
    params.fetch(:beacon, {}).permit(:signal_interval, :transmission_power)
  end

  def role_permitted_params
    current_admin.admin? ? [:manager_id] : []
  end

  def fetched_beacon_params
    params.fetch(:beacon, {})
  end
end