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
    # Basic Extension module. Implements generic class_methods, which can be included
    # into created extension using AS concerns.
    #
    module Extension
      extend ActiveSupport::Concern

      module ClassMethods
        attr_accessor :registered_name

        def register_extension!(gem_name)
          ::BeaconControl::Base.register_extension(gem_name, self)
        end

        #
        # Defines prefix for extension database tables, based on picked extension name.
        # I.e. for +DwellTime+ extension, it will return +ext_dwell_time_+.
        #
        def table_name_prefix
          "ext_#{self.registered_name.to_s.underscore}_"
        end

        #
        # Configures extension.
        #
        # ==== Parameters
        #
        # * <tt>&block</tt> - Ruby block, evaluated in config object context.
        #
        def configure(&block)
          @config = BeaconControl::Base::Config.new &block
        end

        #
        # Returns extension BeaconControl::Base::Config instantiated object.
        #
        def config
          @config ||= BeaconControl::Base::Config.new
        end
      end

    end
  end
end
