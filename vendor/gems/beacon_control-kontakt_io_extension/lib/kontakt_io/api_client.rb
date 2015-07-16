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
    #
    def beacons
      response = request(:get, "/beacon")
      response_to_array(response, "beacons", KontaktIo::Resource::Beacon)
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
    def request(type, path)
      response = connection.send(type) do |req|
        req.url path
        req.params["maxResult"] = 1_000
        req.headers.merge! headers
        yield req if block_given?
      end

      raise KontaktIo::Error.classify(response.status) unless response.success?

      response
    end

    def headers
      {
        'api-key' => @api_key,
        'accept'  => 'application/vnd.com.kontakt+json;version=5',
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
      JSON.parse(response.body)[key].map{|item| model.new(item) } rescue []
    end
  end
end
