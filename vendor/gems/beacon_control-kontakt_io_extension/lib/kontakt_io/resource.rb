require 'active_support/dependencies/autoload'

module KontaktIo
  module Resource
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Beacon
    autoload :Venue
    autoload :Manager
    autoload :Device
    autoload :Status
    autoload :Firmware
    autoload :Config
  end
end