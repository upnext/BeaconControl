###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl

  #
  # Adds authentication with +authenticate_admin!+ before filter. Should be used
  # for admin private pages.
  #
  # ===== Helper methods
  #
  # * +current_admin+   - returns currently logged in admin, decorated
  # * +current_account+ - returns Account object for current_admin
  #
  class AdminController < ::AdminController
  end
end
