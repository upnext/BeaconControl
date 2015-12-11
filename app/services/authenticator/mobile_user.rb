###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Authenticator

  #
  # Authorization for Doorkeeper secured endpoints with 'user' +scope+
  #
  class MobileUser < Base
    def initialize(doorkeeper_params)
      super(doorkeeper_params)
      self.user_client_id = doorkeeper_params[:user_id]
      self.mobile_os      = doorkeeper_params[:os]
      self.environment    = doorkeeper_params[:environment] || 1
      self.token          = doorkeeper_params[:push_token] || ""
    end

    #
    # Returns or creates MobileDevice for valid +application_id+ and +secret+ credentials.
    # Updates device last login timestamp.
    #
    def call
      return unless valid_params? && application_owner.is_a?(Application)

      mobile_device.tap do |device|
        break if device.blank?

        device.last_sign_in_at = DateTime.now
        device.update_correlation_id_from_current_thread
        device.save
      end
    end

    private

    def mobile_device
      user.mobile_devices.with_environment(environment).where({
        push_token:  token,
        os:          mobile_os
      }).first_or_initialize
    end

    def user
      @user ||= application_owner
        .users
        .where(client_id: user_client_id)
        .first_or_create!
    end

    def required_params
      [application_id, secret, user_client_id, mobile_os]
    end

    attr_accessor :user_client_id, :token, :mobile_os, :environment
  end
end
