###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module Base
    class Railtie < Rails::Railtie
      BeaconControl::Base.register_extension(
        'beacon_control-base',
        BeaconControl::Base
      )
      config.before_configuration do |app|
        app.paths['app/models'] << File.expand_path('../../../../app/models', __FILE__)
        app.paths['app/controllers'] << File.expand_path('../../../../app/controllers', __FILE__)
      end

      config.to_prepare do
        BeaconControl::Base.load_extensions!
        BeaconControl::Base.watch_reload.each_pair do |klass, reload_hash|
          klass = klass.constantize
          reload_hash.each_pair do |identity, injections|
            unless klass.const_defined?(identity)
              injections.each do |mod|
                klass.send(:include, mod.constantize)
              end
            end
          end
        end
      end
    end
  end
end
