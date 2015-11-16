###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Serialization of Beacon proximity to store and rebuild from database string.
#
class ProximityId
  include AsyncValue

  IBEACON = 'iBeacon'
  EDDYSTONE = 'Eddystone'
  PROTOCOLS =  [IBEACON,EDDYSTONE]

  EDDYSTONE_FIELDS = [
    :namespace,
    :instance,
    :url
  ]
  IBEACON_FIELDS = [
    :uuid,
    :major,
    :minor
  ]

  FIELDS = [:protocol] | IBEACON_FIELDS | EDDYSTONE_FIELDS

  def self.analise(str)
    args = str.split('+')
    unless PROTOCOLS.include?(args.first)
      args.unshift(IBEACON) # backport
    end
    args
  end

  def self.compatibility_load(beacon, str)
    Rails.logger.warn 'Beacon proximity id compatibility load...'
    proximity = new(beacon)
    args = analise(str)
    FIELDS.each_with_index do |field, index|
      proximity.send("#{field}=", args[index] || '')
    end
    beacon.update_attribute(:proximity_id, nil) # Erase after done
    proximity
  end

  def initialize(beacon)
    @beacon = beacon
    load_values
  end

  def to_s
    FIELDS.reduce([]) { |buffer, field| buffer.push(send(field)); buffer }.join('+')
  end

  def ==(other)
    other.instance_of?(self.class) && to_s == other.to_s
  end

  def eddystone
    EDDYSTONE_FIELDS.reduce([]) { |m, field| m << send(field); m }
  end

  def i_beacon
    IBEACON_FIELDS.reduce([]) { |m, field| m << send(field); m }
  end

  def load_values
    beacon.beacon_proximity_fields.where(name: FIELDS).each do |field|
      instance_variable_set(:"@#{field.name}", field)
    end
  end

  def self.create_proximity_field(field_name)
    return if method_defined? field_name
    define_method(field_name) do
      field = send("load_and_memoize_#{field_name}")
      field.value
    end
    define_method("#{field_name}=") do |value|
      field = send("load_and_memoize_#{field_name}")
      field.value = value
    end
    define_method("load_and_memoize_#{field_name}") do
      val = instance_variable_get(:"@#{field_name}")
      return val if val.present?
      val = if beacon.persisted?
              beacon.beacon_proximity_fields.where(name: field_name).first_or_create(name: field_name)
            else
              beacon.beacon_proximity_fields.where(name: field_name).first_or_initialize(name: field_name)
            end
      instance_variable_set(:"@#{field_name}", val)
      val
    end
  end

  def save(id)
    FIELDS.each do |field_name|
      field = send(:"load_and_memoize_#{field_name}")
      field.beacon_id = id
      field.save
    end
  end

  attr_reader :beacon

  FIELDS.each { |field| create_proximity_field field }
end
