require 'beacon'

class Beacon
  class ConfigObject < OpenStruct
    attr_reader :beacon

    def initialize(beacon, hash)
      super(extension_compatibility(hash))
      @beacon = beacon
    end

    # @param [Hash] hash
    def extension_compatibility(hash)
      hash.each_pair do |key, val|
        hash[key] = ::Beacon::ConfigObject.new(nil, val) if val.is_a?(::Hash)
      end
      hash
    end

    # def proximity
    #   beacon.proximity_id.uuid if beacon
    # end
    #
    # def minor
    #   beacon.proximity_id.minor if beacon
    # end
    #
    # def major
    #   beacon.proximity_id.major if beacon
    # end
    #
    # def namespace
    #   beacon.proximity_id.namespace if beacon
    # end
    #
    # def instance
    #   beacon.proximity_id.instance if beacon
    # end
    #
    # def url
    #   beacon.proximity_id.url if beacon
    # end
  end
end
