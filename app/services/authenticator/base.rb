###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module Authenticator

  #
  # Provides authorization functionality to run against +Doorkeeper::Application+ model.
  # Should be used as parent class.
  #
  class Base
    def initialize(doorkeeper_params)
      self.application_id = doorkeeper_params[:client_id]
      self.secret         = doorkeeper_params[:client_secret]
    end

    def doorkeeper_application
      @doorkeeper_application ||= Doorkeeper::Application.find_by(
        uid:    application_id,
        secret: secret
      )
    end

    def application_owner
      @application_owner ||= doorkeeper_application.owner
    end

    private

    def required_params
      raise NotImplementedError
    end

    def valid_params?
      required_params.all?(&:present?) && doorkeeper_application && application_owner
    end

    attr_accessor :application_id, :secret
  end
end
