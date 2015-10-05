###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AdminController < ApplicationController
  protect_from_forgery with: :exception

  # noinspection RailsParamDefResolve
  before_filter :authenticate_admin!

  def current_admin
    admin = super
    ::AdminDecorator.new(admin) if admin
  end

  def current_account
    current_admin.account
  end
end
