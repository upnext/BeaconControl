###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

class Beacon < ActiveRecord::Base
  include AsyncValue

  AVAILABLE_FLOORS = ((AppConfig.lowest_floor)..(AppConfig.highest_floor)).to_a
  SORTABLE_COLUMNS = %w(beacons.name zones.name floor beacons.created_at beacons.updated_at beacons.protocol)
  PROTOCOLS = %w(iBeacon Eddystone)
  VENDORS = [ 'Other', 'BlueCats', 'BlueSense', 'Estimote', 'Gelo', 'Glimworm', 'Gimbal by Qualcomm', 'Kontakt', 'Beaconinside', 'Sonic Notify' ].sort
  MODE = [ 'Custom', 'Kontakt Beacon', 'Energy saver', 'Power Beacon', 'Apple iBeacon' ]

  include Searchable
  include ProximitySearchable

  belongs_to :account
  belongs_to :manager, class_name: Admin
  belongs_to :zone

  has_many :triggers_sources, ->{ where(source_type: 'Beacon') }, foreign_key: :source_id
  has_many :triggers, through: :triggers_sources

  has_many :applications_beacons, dependent: :delete_all
  has_many :applications, through: :applications_beacons

  has_many :activities, through: :triggers

  has_one :beacon_config,
          dependent: :destroy,
          autosave: true

  has_many :beacon_proximity_fields,
           dependent: :destroy,
           autosave: true

  after_save { proximity_id.save(id) }

  after_validation do
    [:uuid, :major, :minor, :namespace, :instance, :url].each { |key| (errors[key].push *errors[:proximity_id]).uniq! }
  end

  before_destroy do
    activities.with_scheme(:custom).last.destroy if activities.count == 1 && activities.with_scheme(:custom).last
    triggers_sources.destroy_all
  end

  before_save { proximity_id.protocol = protocol }
  before_validation { proximity_id.protocol = protocol }

  validates_with BeaconIdentityValidator

  validates :account,
            presence: true

  validates :floor,
            inclusion: { in: AVAILABLE_FLOORS },
            allow_blank: true

  validates :name,
            presence: true,
            uniqueness: { scope: :account }

  validates :zone_id,
            inclusion: { in: ->(beacon) { beacon.manager.zone_ids} },
            allow_blank: true,
            if: :manager_id?

  validate :validate_manager_role,
           if: :manager_id?

  validates :protocol,
            inclusion: { in: PROTOCOLS }

  validate :validate_test_activity

  validates :vendor,
            inclusion: { in: VENDORS }

  scope :unassigned,    -> { where(zone: nil) }

  scope :with_location, -> {
    where('beacons.lat IS NOT NULL AND beacons.lng IS NOT NULL')
  }

  scope :with_floor,    ->(floor) {
    where(floor: floor == 'null' ? nil : floor) if floor != 'all'
  }

  scope :with_zone_id,  ->(zone_ids) {
    zone_ids.map! {|z| z == 'null' ? nil : z }
    where(zone_id: zone_ids)
  }

  scope :with_name, ->(name) {
    if name.present?
      where('beacons.name LIKE :name', {name: "%#{name}%"})
    end
  }

  scope :with_protocol, ->(name) {
    if name
      where('beacons.protocol LIKE :name', {name: "%#{name}%"})
    end
  }

  scope :with_beacon_or_zone_name, ->(name) {
    if name.present?
      where('beacons.name LIKE :name or zones.name LIKE :name', {name: "%#{name}%"})
    end
  }

  scope :sorted, ->(column, direction) {
    sorted_column = if SORTABLE_COLUMNS.include?(column)
                      column
                    else
                      'beacons.name'
                    end

    direction = if %w[asc desc].include? direction
                  direction
                else
                  'asc'
                end

    order("#{sorted_column} #{direction}")
  }

  delegate :uuid, :uuid=,
           :major, :major=, :minor, :minor=,
           :namespace, :namespace=, :instance, :instance=, :url, :url=,
           to: :proximity_id

  attr_accessor :mode,
                :activity_time

  before_validation do
    self[:proximity_uuid] = encoded_proximity_uuid
  end

  def encoded_proximity_uuid
    Base64.encode64 [uuid, major, minor, namespace, instance, url, protocol].join
  end

  def imported?
    false
  end

  def vendor_uid
  end

  def vendor_uid=(val)
  end

  def proximity_id
    @proximity_id ||= begin
      if read_attribute(:proximity_id).present?
        ProximityId.compatibility_load(self, read_attribute(:proximity_id))
      else
        ProximityId.new(self)
      end
    end
  end

  def config
    if loaded_config_data.__id__ != @config.try(:attributes).__id__
      @config = ConfigObject.new(self, loaded_config_data)
    end
    @config
  end

  def reload_config!
    @config = nil || config
  end

  def loaded_config_data
    (beacon_config || build_beacon_config).loaded_data
  end

  def available_floors
    AVAILABLE_FLOORS
  end

  def to_s
    name
  end

  def test_trigger
    @test_trigger ||= triggers.where(test: true).first
  end

  def test_trigger=(trigger)
    @test_trigger = trigger
  end

  def test_activity
    @test_activity ||= test_trigger && test_trigger.activity
  end

  def test_activity=(activity)
    @test_activity = activity
  end

  def build_test_activity
    self.test_trigger ||= triggers.build
    self.test_activity ||= test_trigger.build_activity
  end

  def assign_test_activity(activity, do_save = false)
    if activity && activity.test && activity.trigger && account.test_application
      # for test activity allow to set only one custom_attribute
      activity.custom_attributes = [activity.custom_attributes.last] if activity.custom_attributes.size > 1
      activity.trigger.application = account.test_application
      activity.trigger.beacons.push(self) unless activity.trigger.beacons.include?(self)
      activity.save if do_save

      self.test_activity = activity
    end
  end

  def update_test_activity(activity_params)
    build_test_activity

    test_activity.assign_attributes(activity_params)
    if test_activity.test
      assign_test_activity(test_activity, true)
    else
      triggers.delete(test_trigger)
    end
  end

  def reload(*)
    super.tap { @config = nil }
  end

  private

  def validate_manager_role
    errors.add(:manager_id, :wrong_role) unless manager && manager.beacon_manager?
  end

  def validate_test_activity
    if test_activity && test_activity.test && !test_activity.valid? && errors[:test_activity].empty?
      errors.add(:test_activity, test_activity.errors.messages)
    end
  end
end
