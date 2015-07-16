###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Admin::SessionsController < Devise::SessionsController  
  respond_to :json

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_to do |format|
      if resource.valid?
        format.html { redirect_to after_sign_in_path_for(resource) }
        format.json { render json: resource, status: 200 }
      else
        format.html { render action: 'new' }
        format.json { render json: resource, status: :unprocessable_entity, root: false, serializer: ErrorSerializer }
      end
    end
  end

  def after_sign_out_path_for(resource_name)
    new_admin_session_path
  end
end
