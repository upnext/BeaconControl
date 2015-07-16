###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class Engine < Rails::Engine
      isolate_namespace BeaconControl::PresenceExtension

      initializer "presence_extension", before: :load_config_initializers do |app|
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end

        config.paths["app/models"].expanded.each do |expanded_path|
          app.config.paths["app/models"] << expanded_path
        end
      end
    end
  end
end
