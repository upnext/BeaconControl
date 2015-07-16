###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RootController < ApplicationController
  protect_from_forgery with: :exception

  before_filter :authenticate_root!

  layout "root"

  private

  def authenticate_root!
    authenticate_or_request_with_http_basic do |username, password|
      username == AppConfig.root[:username] && password == AppConfig.root[:password]
    end
  end
end
