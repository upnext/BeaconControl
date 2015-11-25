require "beacon_control/neighbours_extension/engine" if defined?(Rails)
require "beacon_control/neighbours_extension/version"
require 'sprockets/es6' if defined?(Sprockets)

module BeaconControl
  module NeighboursExtension
    include BeaconControl::Base::Extension
    extend ActiveSupport::Autoload

    autoload :ZoneExtension
    autoload :Neighbour

    self.registered_name = "Neighbours"

    register_extension! 'beacon_control-neighbours_extension'

    def self.table_name_prefix
      "ext_neighbours_"
    end

    # Does files needs to be loaded without constant missing mechanism.
    # For example:
    # * You want add some functionality to model
    # * You want override some class/instance methods
    # @see {BeaconControl::Base#load_extensions!}
    def self.load_files
      []
    end
  end
end
