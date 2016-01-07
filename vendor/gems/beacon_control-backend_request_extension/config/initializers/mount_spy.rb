require 'beacon_control/presence_extension/beacon_presence'

BeaconControl::PresenceExtension::BeaconPresence.send(:after_save) do |presence|
  if presence.present
    ::Activity.where(scheme: :requests).includes(trigger: :beacons).where(beacons: { id: presence.beacon_id }).each do |activity|
      begin
        Rails.logger.info "Sending backend request to: #{activity.url}"
        uri = URI(activity.url)
        params = {
            beacon_id: presence.beacon_id
        }
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get_response(uri)
      rescue StandardError => error
        Rails.logger.warn error
      end
    end
  end
end