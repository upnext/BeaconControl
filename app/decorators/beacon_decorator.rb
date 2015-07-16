###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BeaconDecorator < Draper::Decorator
  delegate_all

  def self.available_floors
    Beacon::AVAILABLE_FLOORS
  end

  def self.floors_for_select(unassigned_floor, reverse=false)
    unassigned_floor = unassigned_floor.is_a?(Array) ? unassigned_floor : [nil, unassigned_floor]
    options = available_floors.zip(available_floors.map { |floor| floor.ordinalize }).unshift(unassigned_floor)
    options.map!(&:reverse) if reverse
    options
  end

  # @return [TrueClass|FalseClass]
  def zone_name?
    zone_name.present?
  end

  # @return [String]
  def zone_name
    zone ? zone.name : ''
  end
end
