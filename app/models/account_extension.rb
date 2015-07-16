###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class AccountExtension < ActiveRecord::Base
  self.primary_keys = :account_id, :extension_name

  belongs_to :account
  has_many :extension_settings, foreign_key: [:account_id, :extension_name], dependent: :destroy
  accepts_nested_attributes_for :extension_settings

  def extension
    ExtensionsRegistry.find(extension_name)
  end

  #
  # Builds collection of all required Extension configuration settings.
  #
  def build_extension_configurations
    extension.configurations.each do |ext_configuration|
      extension_settings.new(key: ext_configuration[:key]) unless
        extension_settings.where(key: ext_configuration[:key]).present?
    end
  end

  #
  # Finds Extension setting value by setting name.
  #
  def extension_setting(name)
    extension_settings.find{ |setting| setting.key == name.to_s }
  end
end
