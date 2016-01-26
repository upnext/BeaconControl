###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Admin::PasswordsController < Devise::PasswordsController  
  respond_to :json

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    resource.errors.add(:password_confirmation, :mismatch) unless resource.password == resource.password_confirmation

    if resource.errors.empty?
      update_password!
    else
      respond_with resource
    end
  end

  private

  def update_password!
      resource.confirm! if confirmable?(resource)
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
  end

  def confirmable?(resource)
    !resource.active_for_authentication?
  end
end
