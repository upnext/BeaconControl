###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Custom application setting, that could be added by extension
#
class ApplicationSetting < ActiveRecord::Base
  belongs_to :application

  #
  # Available ApplicationSetting subclasses for +ActiveRecord+ STI.
  #
  enum type: {
    string: 'ApplicationSetting::StringSetting',
    text: 'ApplicationSetting::TextSetting',
    password: 'ApplicationSetting::PasswordSetting',
    file: 'ApplicationSetting::FileSetting'
  }

  validates :extension_name,
    presence: true,
    inclusion: { in: Proc.new{ |setting| setting.application.active_extensions.map(&:name)} }

  validates :key,
    presence: true,
    length: { maximum: 255 },
    inclusion: { in: :valid_keys },
    uniqueness: { scope: :extension_name }

  validates :type,
    presence: true,
    inclusion: { in: types.keys }

  #
  # Injects setting validations added dynamically by extension, in +config[:validations]+.
  # Options are evaluated in context of setting object, so they could define custom validation
  # method to run. Config could be defined like:
  #
  #   Proc.new{ { presence: true, length: { minimum: 3, maximum: 6 } } }
  #
  before_validation do
    if config && config[:validations] && self.class.validators_on(:value).empty?
      self.class.validates :value, instance_eval(&config[:validations])
    end
  end

  #
  # Setting configuration hash provided by extension initializer.
  #
  def config
    @config ||= extension.settings.detect{ |setting| setting[:key] == key.try(:to_sym) } if extension
  end

  private

  def extension
    @extension ||= ExtensionsRegistry.find(extension_name)
  end

  def valid_keys
    extension.settings.map{ |setting| setting[:key].to_s } rescue []
  end
end
