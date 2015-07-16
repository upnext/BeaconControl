###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Custom Extension configuration option, required for proper functioning.
#
class ExtensionSetting < ActiveRecord::Base
  #
  # Uses composite keys
  #
  belongs_to :account_extension, foreign_key: [:account_id, :extension_name]

  validates :key, presence: true, length: { maximum: 255 }

  def extension
    ExtensionsRegistry.find(extension_name)
  end

  def config
    @config ||= extension.configurations.detect{ |configuration| configuration[:key] == key.to_sym }
  end
end
