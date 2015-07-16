###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Admin::ConfirmationsController < Devise::ConfirmationsController

  before_action :find_by_confirmation_token, only: [:show, :update]
  before_action :logout_current_admin, only: [:show]

  def show
    unless resource.errors.empty?
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  def update
    if resource.update(change_password_params)
      resource.confirm!
      sign_in(resource_name, resource)
      set_flash_message(:notice, :confirmed) if is_flashing_format?

      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      render :show
    end
  end

  private

  # Find a user by its confirmation token.
  # If no user is found, returns a new user with an error.
  # If the user is already confirmed, create an error for the user
  def find_by_confirmation_token
    original_token = params[:confirmation_token]
    confirmation_token = Devise.token_generator.digest(resource_class, :confirmation_token, original_token)
    self.resource = resource_class.find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
  end

  def logout_current_admin
    sign_out current_admin if current_admin
  end

  def change_password_params
    params.required(:admin).permit(:password, :password_confirmation)
  end
end
