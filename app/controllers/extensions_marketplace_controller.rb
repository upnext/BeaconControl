###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ExtensionsMarketplaceController < AdminController
  inherit_resources
  before_action :find_configurable_account_extension, only: [:edit, :update]
  before_action :build_extension_configurations, only: [:edit]
  before_action :authorize_resource, only: [:activate, :deactivate, :edit, :update]
  before_action :check_configuration_required, only: [:activate]

  def activate
    current_account.activate_extension(resource)

    redirect_to extensions_marketplace_index_path
  end

  def deactivate
    current_account.deactivate_extension(resource)

    redirect_to extensions_marketplace_index_path
  end

  def update
    @account_extension.update_attributes(permitted_params)

    render :edit
  end

  private

  def collection
    ExtensionsRegistry.registry_set.select{ |ext| can?(:manage, ext) }
  end

  def resource
    ExtensionsRegistry.find(params[:id])
  end

  def find_configurable_account_extension
    if resource.configurations
      @account_extension = current_account.account_extensions.find_or_initialize_by(extension_name: resource.name)
    else
      redirect_to :back
    end
  end

  def build_extension_configurations
    @account_extension.build_extension_configurations
  end

  def begin_of_association_chain
    current_admin.account
  end

  helper_method :active_extensions, :inactive_extensions
  def inactive_extensions
    Set.new(current_account.inactive_extensions) & collection
  end

  def active_extensions
    Set.new(current_account.active_extensions) & collection
  end

  def check_configuration_required
    redirect_to edit_extensions_marketplace_path(resource) if resource.configurations
  end

  def permitted_params
    params.require(:account_extension).permit(
      extension_settings_attributes: [:id, :key, :value]
    )
  end

  def authorize_resource
    authorize! :manage, resource
  end
end
