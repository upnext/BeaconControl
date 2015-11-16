###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module KontaktIo

  #
  # Kontakt.io API client
  #
  class ApiClient
    API_VERSION = 7

    #
    # Initializer
    #
    # ==== Parameters
    #
    # * +api_key+ - String, Kontakt.io API key, required in every request.
    #
    def initialize(api_key)
      @api_key = api_key
    end

    # @param [Admin] admin
    def self.for_admin(admin)
      KontaktIo::ApiClient.new(
        KontaktIo::ApiClient.account_api_key(admin.account)
      )
    end

    # @param [Account] account
    def self.for_account(account)
      KontaktIo::ApiClient.new(
        KontaktIo::ApiClient.account_api_key(account)
      )
    end

    #
    # Fetches all Kontakt.io managers assigned to an account from GET /manager endpoint.
    # Returns array of +KontaktIo::Resource::Manager+ objects for each manager.
    #
    def managers
      response = request(:get, "/manager")
      response_to_array(response, "managers", KontaktIo::Resource::Manager)
    end

    #
    # Fetches all Kontakt.io beacons assigned to an account from GET /beacon endpoint.
    # Returns array of +KontaktIo::Resource::Beacon+ objects for each beacon.
    # @deprecated
    def beacons(params={})
      devices(params)
    end

    def beacon(uuid, params={})
      device(uuid, params)
    end

    def venues(params={})
      response = request(:get, "/venue", params)
      response_to_array(response, "venues", KontaktIo::Resource::Venue)
    end

    def devices(params={})
      response = request(:get, "/device", params)
      response_to_array(response, 'devices', KontaktIo::Resource::Device)
    end

    def device(uuid, params={})
      response = request(:get, "/device/#{uuid}", params)
      response_to_instance(response, KontaktIo::Resource::Device)
    end

    def device_status(uuid)
      hash = load_hash_from("/device/#{uuid}/status")
      KontaktIo::Resource::Status.new(hash)
    end

    def device_firmware(uuid)
      hash = load_hash_from("/firmware/last", {uniqueId: uuid})
      KontaktIo::Resource::Firmware.new(hash[uuid])
    end

    def device_config(uuid)
      hash = load_hash_from("/config/#{uuid}")
      KontaktIo::Resource::Config.new(hash)
    end

    def update_device(uuid, device_type, data)
      response = request(:post, '/device/update', {uniqueId: uuid, deviceType: device_type}.merge(data))
      response.body
    end

    # @param [String] uuid
    # @param [String] device_type
    # @param [Hash] data
    def update_config(uuid, device_type, data)
      current = load_hash_from("/device/#{uuid}").with_indifferent_access
      hash = {}.with_indifferent_access
      data = data.with_indifferent_access
      %w[interval txPower].each do |key|
        hash[key] = data[key] if data[key] != current[key] && data.key?(key)
      end
      hash.merge!(uniqueId: uuid, deviceType: device_type)
      response = request(:post, '/config/create', hash)
      response.body
    end

    private def load_hash_from(url, params={})
      return JSON.parse(request(:get, url, params).body)
    rescue KontaktIo::Error::NotFound
      return {}
    end

    #
    # Finds Kontakt.io API key stored in database.
    #
    # ==== Parameters
    #
    # * +for_account+ - Account instance, for which key should be found
    #
    def self.account_api_key(for_account)
      for_account
        .account_extensions
        .find_by(extension_name: BeaconControl::KontaktIoExtension.registered_name)
        .extension_setting(:api_key)
        .try :value
    end

    private

    def connection
      @connection ||= Faraday.new(url: 'https://api.kontakt.io') do |faraday|
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end
    end

    #
    # Performs request using Faraday client. Extra headers or parameters could
    # be provided by passing block. Raises exception if request fails.
    #
    # ==== Parameters
    #
    # * +type+ - symbol, type of request to perform: +:get+, +:post+
    # * +path+ - string, URI path to get
    #
    # ==== Example
    #
    #   => request(:get, "/test") do
    #   =>   req.params["foo"] = "bar"
    #   =>   req.headers["page"] = 1
    #   => end
    #
    # will access +/test?foo=bar+ endpoint with extra header key +page+ = 1
    #
    def request(type, path, params={})
      response = connection.send(type) do |req|
        req.url path
        req.params.merge!({"maxResult" => 1_000}.merge(params))
        req.headers.merge! headers
        yield req if block_given?
      end

      if Rails.env.production?
        raise KontaktIo::Error.classify(response.status) unless response.success?
      end

      response
    end

    def headers
      {
        'api-key' => @api_key,
        'accept'  => "application/vnd.com.kontakt+json;version=#{API_VERSION}",
        'url'     => 'https://api.kontakt.io'
      }
    end

    #
    # Maps Faraday response body in JSON format to an array of +KontaktIo::Resource::ResourceName+ Virtus objects.
    #
    # ==== Parameters
    #
    # * +response+ - Faraday::Response instance
    # * +key+      - string, response JSON key to fetch & parse
    # * +model+    - Class, KontaktIo::Resource class to instantiate for each returned resource
    #
    def response_to_array(response, key, model)
      hash = JSON.parse(response.body)
      Rails.logger.debug(hash.inspect) if Rails.env.development?
      if hash.key?(key)
        (key ? hash[key] : hash).map do |item|
          model.new(item)
        end
      else
        model.new(hash)
      end
    rescue => error
      Rails.logger.error error.message
      Rails.logger.error error.backtrace.join("\n")
      []
    end

    def response_to_instance(response, model)
      hash = JSON.parse(response.body)
      Rails.logger.debug(hash.inspect) if Rails.env.development?
      model.new(hash)
    rescue => error
      Rails.logger.error error.message
      Rails.logger.error error.backtrace.join("\n")
      []
    end
  end
end
