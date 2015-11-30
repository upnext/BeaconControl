###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

class ApplicationController < ActionController::Base
  force_ssl if: -> { AppConfig.force_ssl }
  before_action :set_application_url


  def current_ability
    @current_ability ||= Ability.new(current_admin)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  def set_application_url
    if ActionMailer::Base.default_url_options[:host] != request.host
      ActionMailer::Base.default_url_options[:host] = AppConfig.mailer_url_options[:host] = request.host
    end
  end
end
