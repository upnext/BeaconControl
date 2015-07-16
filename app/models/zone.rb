###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Zone < ActiveRecord::Base
  belongs_to :account
  belongs_to :manager, class_name: Admin
  has_many :beacons, dependent: :nullify
  has_many :applications_zones, dependent: :delete_all
  has_many :applications, through: :applications_zones

  has_many :triggers_sources, ->{ where(source_type: 'Zone') }, foreign_key: :source_id, dependent: :destroy
  has_many :triggers, through: :triggers_sources

  accepts_nested_attributes_for :beacons

  attr_accessor :move_beacons

  before_save :change_beacons_assignment
  after_initialize { |record| record.color ||= ZoneColors.sample }

  validates :name,
    presence: true

  validates :account,
    presence: true

  validate :validate_manager_role, if: :manager_id?

  validates :color, format: { with: ZoneColors.insensitive_matcher }, presence: true

  #
  # Filter Zone collection by +name+
  #
  # ==== Parameters
  #
  # * +q+                    - Hash, parameters to filter. Valid keys:
  #   * +:name+              - filters zones by +name+
  # * +begin_of_association+ - additional scope to be applied to returned collection
  #
  def self.search(q)
    where(q.blank? ? nil : "name LIKE ?", "%#{q[:name]}%")
  end

  def as_json
    {
      id: id,
      name: name,
      beacon_ids: beacon_ids
    }
  end

  def hex_color
    return 'transparent' if color.blank?

    "##{color}"
  end

  private

  #
  # Prevents assigning beacons to zone with different manager. Forces moving beacon to other
  # manager's zone if +move_beacons+ attribute is set.
  #
  def change_beacons_assignment
    if move_beacons == 'true'
      beacons.update_all(manager_id: manager_id)
    elsif beacon_ids.present?
      self.beacons = beacons.select{|b| b.manager_id == manager_id}
    end
  end

  def validate_manager_role
    errors.add(:manager_id, :wrong_role) unless manager && manager.beacon_manager?
  end
end
