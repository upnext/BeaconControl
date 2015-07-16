###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ProfilesController < AdminController
  def update
    current_admin.update_attributes(permitted_params)

    render template: 'admins/registrations/edit'
  end

  private

  def permitted_params
    params.require(:admin).permit(:default_beacon_uuid)
  end

  def resource
    current_admin
  end
  helper_method :resource

  def resource_name
    :admin
  end
  helper_method :resource_name
end
