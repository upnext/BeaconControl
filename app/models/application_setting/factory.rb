###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationSetting::Factory

  def initialize(application)
    @application = application
  end

  #
  # Builds list of ApplicationSetting for given application. For settings already persisted
  # in database, corresponding row will be fetched. For settings not saved yet, new object will
  # be built & initialized.
  #
  def build
    @application.active_extensions.each do |ext|
      ext.settings.each do |ext_setting|
        @application.application_settings.new(
          type: sti_class(ext_setting[:type]),
          application_id: @application.id,
          extension_name: ext.name,
          key: ext_setting[:key]) unless setting_present?(ext.name, ext_setting)
      end
    end
  end

  #
  # Based on given parameters:
  #   * updates application settings if matching by +extension_name+ and +key+ was found in database
  #   * removes setting if matching was found in database and new value is not provided
  #   * creates new setting otherwise
  #
  # ==== Parameters
  #
  # * +params+ - Array of settings attributes from request
  #
  def update(params)
    (params[:application_settings] || []).each do |app_setting|
      if setting = @application.application_settings.find_by(extension_name: app_setting[:extension_name], key: app_setting[:key])
        if app_setting[:value]
          setting.update_attributes setting_params(app_setting)
        else
          setting.destroy
        end
      else
        @application.application_settings.create setting_params(app_setting)
      end
    end
  end

  private

  # :doc:
  # Checks if setting is present in database.
  #
  # ==== Parameters
  #
  # * +extension_name+ - String, name of extension to check setting presence
  #   (multiple extensions could add settings with the same name)
  # * +ext_setting+    - Hash, setting configuration options. Key +:key+ is required
  #   to identify requested setting
  #
  def setting_present? extension_name, ext_setting # :doc:
    @application.application_settings
      .detect{ |setting| setting.extension_name == extension_name && setting.key == ext_setting[:key].to_s }
      .present?
  end

  #
  # Builds name of setting class for STI.
  #
  # ==== Parameters
  #
  # * +type+ - String, type of settng. Currently supported values:
  #   * +:file+
  #   * +:password+
  #   * +:string+
  #   * +:text+
  #
  def sti_class(type) # :doc:
    "ApplicationSetting::#{type.to_s.classify}Setting"
  end

  #
  # Builds settings parameters, maps setting type from +string,password,text,file+
  # to corresponding STI models names.
  #
  def setting_params(params)
    params.tap do
      params[:type] = ApplicationSetting.types[params[:type]] || "ApplicationSetting::StringSetting"
    end
  end
end
