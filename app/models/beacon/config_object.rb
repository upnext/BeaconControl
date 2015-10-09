require 'beacon'
class Beacon
  class ConfigObject < OpenStruct
    def initialize(hash)
      super extension_compatibility(hash)
    end

    # @param [Hash] hash
    def extension_compatibility(hash)
      hash.each_pair do |key, val|
        hash[key] = Beacon::ConfigObject.new(val) if val.is_a?(Hash)
      end
      hash
    end

    %w[transmission_power signal_interval].each do |mth|
      class_eval "def #{mth};super;end"
      class_eval "def #{mth}=(*);super;end"
    end
  end
end