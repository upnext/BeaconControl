###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ExtensionsController < AdminController
  inherit_resources

  helper_method :application, :active_extensions, :inactive_extensions

  before_filter :application

  def index
  end

  def activate
    application.activate_extension(resource)

    render :index
  end

  def deactivate
    application.deactivate_extension(resource)

    render :index
  end

  private

  def resource
    ExtensionsRegistry.find(params[:id])
  end

  def application
    @application ||= Application.find(params[:application_id]).decorate
  end

  def active_extensions
    application.active_extensions
  end

  def inactive_extensions
    current_account.active_extensions - application.active_extensions
  end
end
