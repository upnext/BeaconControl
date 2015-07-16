###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rpush'

class Application < ActiveRecord::Base
  APNS_APP = 'Rpush::Client::ActiveRecord::Apns::App'
  GCM_APP  = 'Rpush::Client::ActiveRecord::Gcm::App'

  belongs_to :account

  has_many :triggers
  has_many :activities, through: :triggers
  has_many :beacons, through: :account
  has_many :zones,   through: :account

  has_many :application_extensions

  has_many :application_settings, dependent: :destroy

  # Private
  has_many :rpush_apps, class_name: 'Rpush::Client::ActiveRecord::App'

  has_one :apns_app_production, ->{ where(rpush_apps: { environment: 'production' }) }, class_name: APNS_APP
  has_one :apns_app_sandbox,    ->{ where(rpush_apps: { environment: 'sandbox' }) },    class_name: APNS_APP
  has_one :gcm_app,             class_name: GCM_APP

  has_many :users
  has_many :mobile_devices, through: :users

  has_one :doorkeeper_application,
    class_name: 'Doorkeeper::Application',
    as: :owner

  accepts_nested_attributes_for :apns_app_production
  accepts_nested_attributes_for :apns_app_sandbox
  accepts_nested_attributes_for :gcm_app
  accepts_nested_attributes_for :application_settings

  validates :name, presence: true, uniqueness: { scope: :account }

  delegate :uid, :secret, to: :doorkeeper_application

  before_destroy :check_if_test_app

  def rpush_app_for_device(mobile_device)
    Application::PushApp.new(self, mobile_device).find
  end

  def active_extensions
    ExtensionsRegistry.active_extensions_for(application_extensions)
  end

  def inactive_extensions
    ExtensionsRegistry.inactive_extensions_for(application_extensions)
  end

  def activate_extension(extension)
    application_extensions.where(extension_name: extension.to_s).first_or_create
  end

  def deactivate_extension(extension)
    application_extensions.where(extension_name: extension.to_s).delete_all
  end

  def extension_active?(extension)
    application_extensions.where(extension_name: extension.to_s).exists?
  end

  def extension_by_name(extension)
    application_extensions.find_by(extension_name: extension.to_s)
  end

  private

  def check_if_test_app
    !self.test
  end
end
