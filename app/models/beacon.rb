###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Beacon < ActiveRecord::Base
  AVAILABLE_FLOORS = ((AppConfig.lowest_floor)..(AppConfig.highest_floor)).to_a
  SORTABLE_COLUMNS = %w(beacons.name zones.name floor beacons.created_at)
  VENDORS = [ 'Other', 'BlueCats', 'BlueSense', 'Estimote', 'Gelo', 'Glimworm', 'Gimbal by Qualcomm', 'Kontakt', 'Sensorberg', 'Sonic Notify' ]

  extend UuidField

  include Searchable

  belongs_to :account
  belongs_to :manager, class_name: Admin
  belongs_to :zone, counter_cache: true

  has_many :triggers_sources, ->{ where(source_type: 'Beacon') }, foreign_key: :source_id
  has_many :triggers, through: :triggers_sources

  has_many :applications_beacons, dependent: :delete_all
  has_many :applications, through: :applications_beacons

  has_many :activities, through: :triggers
  #
  # Includes +UuidField+ module functionality.
  #
  uuid_field :uuid, validations: { presence: true, allow_blank: false }

  serialize :proximity_id, ProximityId

  after_validation do
    [:uuid, :major, :minor].each { |key| (errors[key].push *errors[:proximity_id]).uniq! }
  end

  before_destroy do
    activities.with_scheme(:custom).last.destroy if activities.count == 1 && activities.with_scheme(:custom).last
    triggers_sources.destroy_all
  end

  validates :proximity_id,
    uniqueness: { scope: :account },
    presence: true

  validates :major, :minor,
    presence: true,
    numericality: true

  validates :account,
    presence: true

  validates :floor, inclusion: { in: AVAILABLE_FLOORS }, allow_blank: true

  validates :name, presence: true, uniqueness: { scope: :account }

  validates :zone_id, inclusion: { in: lambda { |beacon| beacon.manager.zone_ids} },
    allow_blank: true, if: :manager_id?

  validate :validate_manager_role, if: :manager_id?

  validate :validate_test_activity

  validates :vendor, inclusion: { in: VENDORS }

  scope :unassigned,    -> { where(zone: nil) }
  scope :with_location, -> { where('beacons.lat IS NOT NULL AND beacons.lng IS NOT NULL') }
  scope :with_floor,    ->(floor) {
    if floor != 'all'
      where(floor: floor == 'null' ? nil : floor)
    end
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

  delegate :uuid, :uuid=, :major, :major=, :minor, :minor=, to: :proximity_id

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

  def update_test_activity(activity_permitted_params)
    build_test_activity

    test_activity.assign_attributes(activity_permitted_params)
    if test_activity.test
      assign_test_activity(test_activity, true)
    else
      triggers.delete(test_trigger)
    end
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
