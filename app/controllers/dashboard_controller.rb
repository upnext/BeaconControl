###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class DashboardController < AdminController
  skip_before_filter :authenticate_admin!, only: [:index]

  before_filter :redirect_to_login, unless: :current_admin

  def index
    @walkthrough = !current_admin.walkthrough
    current_admin.update_attribute(:walkthrough, true)
  end

  private

  def redirect_to_login
    redirect_to new_admin_session_url
  end
end
