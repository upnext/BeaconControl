###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

class Admin::RegistrationsController < Devise::RegistrationsController
  include ApplicationController::ParamsExtendable

  extendable :params,
             as: :sign_up_params

  extend_params :sign_up_params,
                fetch: :admin,
                permit: [:email, :password, :password_confirmation]

  respond_to :json

  rescue_from Gibbon::MailChimpError do |error|
    render json: { error: error.body.fetch('title', 'unknown error') },
           status: :unprocessable_entity
  end

  def create
    @admin = Admin::Factory.new(sign_up_params).create

    if @admin.persisted?
      location = nil
      if @admin.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(:admin, @admin)
        location = after_sign_up_path_for(@admin)
      else
        set_flash_message :notice, :"signed_up_but_#{@admin.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        location = after_inactive_sign_up_path_for(@admin)
      end
      Mailchimp::List.find(AppConfig.mailchimp_list_id).members.create(
          email_address: sign_up_params.fetch(:email),
          status: "subscribed"
      ) if AppConfig.mailchimp_list_id.present?
      respond_with @admin, location: location
    else
      clean_up_passwords(@admin)
      # respond_with @admin returns wrong formatted json
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @admin, status: :unprocessable_entity, root: false, serializer: ErrorSerializer }
      end
    end
  end

  private

  def after_inactive_sign_up_path_for(resource)
    new_admin_session_path
  end
end
