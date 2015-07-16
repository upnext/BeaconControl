###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module Base

    #
    # Extension configuration class. Registers and keeps track of provided exension options.
    #
    class Config
      attr_accessor :registers, :autoloadable, :setting_link

      def initialize
        @registers = {
          sidebar_links: [],
          actions: [],
          settings: [],
          configurations: [],
          triggers: []
        }

        yield(self) if block_given?
      end

      #
      # Adds given setting option to proper register.
      #
      # ==== Parameters
      #
      # * +setting+ - Symbol, name of setting to register. Available options:
      #   * +:sidebar_links+
      #   * +:actions+
      #   * +:settings+
      #   * +:configurations+
      #   * +:triggers+
      # * +params+ - Hash of options for given setting.
      #
      def register(setting, params)
        @registers[setting] << params
      end
    end

  end
end
