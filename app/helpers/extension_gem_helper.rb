###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module ExtensionGemHelper

  #
  # Creates HTML for exntension link in left sidebar.
  #
  # ==== Parameters
  #
  # * +params+ - Hash, parameters of link to create from extension configuration
  # * +ctx+    - Context in which link url should be evaluated
  #
  def ext_sidebar_link(params, ctx)
    active_link_to awesome_icon(params[:icon], I18n.t(params[:i18n_key])),
                   ctx.instance_eval(&params[:path])
  end

  #
  # Creates href of link for exntension in application extensions page.
  #
  # ==== Parameters
  #
  # * +extension+ - Extension, with url of link to create from extension configuration
  # * +ctx+       - Context in which link url should be evaluated
  #
  def ext_setting_link(extension, ctx)
    extension.setting_link ? ctx.instance_eval(&extension.setting_link) : '#'
  end

  #
  # Checks if Extension has a partial for global settings defined in +extensions_marketplace+
  # views and renders it.
  #
  # ==== Parameters
  #
  # * +extension_name+ - String, name of extension which should define partial
  #
  def ext_configuration_partial(extension_name)
    lookup_path = [
      "beacon_control",
      "#{extension_name.parameterize.underscore}_extension",
      "extensions_marketplace"
    ].join("/")

    if lookup_context.template_exists?("form", lookup_path, true)
      render partial: "#{lookup_path}/form"
    end
  end
end
