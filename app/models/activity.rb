###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Activity < ActiveRecord::Base

  #
  # Array of available schemes for Activity, includes schemes registered by extensions.
  #
  SCHEMES = %w[url coupon custom] + ExtensionsRegistry.extensions_schemes

  DEFAULT_SCHEME = 'coupon'

  has_one :trigger, dependent: :destroy

  delegate :name,         to: :trigger, prefix: true, allow_nil: true
  delegate :test,         to: :trigger, prefix: false, allow_nil: true
  delegate :source_range, to: :trigger, prefix: true, allow_nil: true

  has_many :custom_attributes, dependent: :destroy

  # Custom Payload
  has_one :coupon

  serialize :payload

  accepts_nested_attributes_for :custom_attributes, allow_destroy: true
  accepts_nested_attributes_for :trigger
  accepts_nested_attributes_for :coupon

  before_save :update_url, if: :coupon?
  after_initialize :set_default_scheme
  after_initialize :set_default_payload

  validates :scheme, inclusion: { in: SCHEMES }
  validates :name, presence: true
  validates :trigger, presence: true

  scope :with_scheme, ->(scheme) { where(scheme: scheme) }

  delegate :url_helpers, to: 'Rails.application.routes'

  def url
    @url || (payload || {})[:url]
  end

  def url=(value)
    value = "http://#{value}" unless value[/\Ahttps?:\/\//]

    (@url = value).tap do
      self.payload = { url: @url }
    end
  end

  def url_without_protocol
    url.to_s.gsub(/\Ahttps?:\/\//, '')
  end

  def coupon?
    scheme == 'coupon'
  end

  def campaign_id=(value)
    self.payload ||= {}
    self.payload[:id] = value
  end

  def campaign_id
    (payload || {})[:id]
  end

  def notification_for_device(mobile_device)
    Activity::Notification.new(mobile_device, self).build
  end

  private

  def update_url
    if coupon.present?
      coupon.save unless coupon.persisted?
      self.url = url_helpers.mobile_coupon_url(coupon, host: AppConfig.coupon_url)
    end
  end

  def set_default_scheme
    self.scheme ||= DEFAULT_SCHEME
  end

  def set_default_payload
    self.payload ||= {}
  end
end
