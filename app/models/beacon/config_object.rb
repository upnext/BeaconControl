require 'beacon'

class Beacon
  class ConfigObject < OpenStruct
    attr_reader :beacon
    include AsyncValue

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

    def attributes
      @table
    end

    def has_own_key?(key)
      @table.key?(key.to_s.to_sym)
    end
  end
end
