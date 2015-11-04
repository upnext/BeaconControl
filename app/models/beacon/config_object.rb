require 'beacon'

class Beacon
  class ConfigObject < OpenStruct
    attr_reader :beacon

    def initialize(beacon, hash)
      @beacon = beacon
      super extension_compatibility(hash)
    end

    # @param [Hash] hash
    def extension_compatibility(hash)
      hash.each_pair do |key, val|
        hash[key] = Beacon::ConfigObject.new(beacon, val) if val.is_a?(Hash)
      end
      hash
    end

    def proximity
      beacon.try(:uuid)
    end

    def minor
      beacon.try(:minor)
    end

    def major
      beacon.try(:major)
    end
  end
end
