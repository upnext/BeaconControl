###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Application
  class PushApp
    delegate :os, :environment, to: :mobile_device

    def initialize(application, mobile_device)
      self.application   = application
      self.mobile_device = mobile_device
    end

    def find
      case os
      when 'ios'     then ios_app
      when 'android' then android_app
      end
    end

    private

    def ios_app
      case environment
      when 'production' then application.apns_app_production
      when 'sandbox'    then application.apns_app_sandbox
      end
    end

    def android_app
      application.gcm_app
    end

    attr_accessor :application, :mobile_device
  end
end
