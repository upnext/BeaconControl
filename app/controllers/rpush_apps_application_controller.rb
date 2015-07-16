###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RpushAppsApplicationController < AdminController
  def destroy
    app = application.rpush_apps.find(params[:id])

    app.destroy!

    redirect_to edit_application_path(application)
  end

  def application
    @application = Application.find(params[:application_id])
  end
end
