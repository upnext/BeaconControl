###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module Api
    module V1

      #
      # Adds API authorization with +doorkeeper_authorize!+ before_action.
      #
      # ===== Helper methods
      #
      # * +current_user+   - returns authorized user
      # * +current_device+ - returns MobileDevice object for authorized user
      # * +application+    - returns +Doorkeeper::Application+ application object for authorized user
      #
      class BaseController < ::Api::V1::BaseController
      end
    end
  end
end
