###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Trigger < ActiveRecord::Base
  before_save :ensure_one_trigger_source
  # Remember to add proper values in config/locales
  TYPES = %w[enter leave near far immediate]
  BEACON_SUPPORTED_TYPES = %w[enter leave near far immediate]
  ZONE_SUPPORTED_TYPES =   %w[enter leave]

  belongs_to :application
  belongs_to :activity

  has_many :triggers_sources
  has_many :beacons, through: :triggers_sources, source: :source, source_type: 'Beacon'
  has_many :zones,   through: :triggers_sources, source: :source, source_type: 'Zone'

  validates :event_type,       inclusion: { in: :valid_types }
  validates :triggers_sources, presence: true
  validates :type,             presence: true
  after_validation do
    [:add_beacon, :add_zone].each{ |key| errors[key].push *errors[:triggers_sources] }
  end

  def name
    I18n.t("triggers.#{event_type}", default: I18n.t('triggers.default'))
  end

  def source_range
    I18n.t("triggers.range.#{type}", default: I18n.t('triggers.default'))
  end

  #
  # Returns list of valid +event_type+ values for trigger registered by Application extensions.
  #
  # ==== Parameters
  #
  # * +application+ - Application instance to check active extensions
  #
  def self.extensions_types(application)
    return [] unless application

    application.active_extensions.map do |extension|
      extension.triggers.map{ |trigger| trigger[:key].to_s }
    end.flatten
  end

  private

  #
  # Makes sure Trigger is responding to only one event originator: Beacon or Zone.
  #
  def ensure_one_trigger_source # :doc:
    self.zone_ids   = [] if type == "BeaconTrigger"
    self.beacon_ids = [] if type == "ZoneTrigger"
    true
  end

  #
  # Array of valid +event_type+ values.
  #
  def valid_types
    TYPES + Trigger.extensions_types(self.application)
  end
end
