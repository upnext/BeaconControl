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

      config.before_eager_load { BeaconControl::Base.exec_load }

      config.to_prepare { BeaconControl::Base.exec_load }
    end
  end
end
