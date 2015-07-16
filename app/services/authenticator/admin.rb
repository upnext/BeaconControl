###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Authenticator

  #
  # Authorization for Doorkeeper secured endpoints with 'admin' +scope+
  #
  class Admin < Base
    def initialize(doorkeeper_params)
      super(doorkeeper_params)
      self.email    = doorkeeper_params[:email]
      self.password = doorkeeper_params[:password]
    end

    #
    # For valid +application_id+ and +secret+ parameters, returns Admin if
    # correct login credentials were provided. Updates last login timestamp.
    #
    def call
      return unless valid_params? && application_owner.is_a?(Brand)

      admin.tap do |admin|
        break unless admin && admin.valid_password?(password) && admin.active_for_authentication?

        admin.last_sign_in_at = DateTime.now
        admin.update_correlation_id_from_current_thread
        admin.save
      end
    end

    private

    def admin
      @admin ||= application_owner
        .admins
        .where(email: email)
        .first
    end

    def required_params
      [application_id, secret, email, password]
    end

    attr_accessor :email, :password
  end
end
