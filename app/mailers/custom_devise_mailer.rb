###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class CustomDeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  default from: AppConfig.mailer_sender

  def confirmation_instructions(record, token, opts={})
    opts[:from] = AppConfig.registration_mailer_sender
    opts[:reply_to] = AppConfig.registration_mailer_sender
    super
  end
end
