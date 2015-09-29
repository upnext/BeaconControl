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
  IBEACON = 'iBeacon'
  EDDYSTONE = 'Eddystone'
  PROTOCOLS =  [IBEACON,EDDYSTONE]

  FIELDS = [
    :protocol,
    :uuid,
    :major,
    :minor,
    :namespace,
    :instance,
    :url
  ]

  # Creates +ProximityId+ instance
  #
  # ==== Parameters
  #
  # * +value+ - String, serialized proximity
  #
  # ==== Example
  #
  #   ProximityId.load("8DD8E67D-89C7-4916-ACB9-153F63927CD0+5+8") #=> <ProximityId @major="5", @minor="8", @uuid="8DD8E67D-89C7-4916-ACB9-153F63927CD0">
  #
  def self.load(value)
    new analise(value.to_s)
  end

  def self.analise(str)
    args = str.split('+')
    unless PROTOCOLS.include?(args.first)
      args.unshift(IBEACON) # backport
    end
    args
  end

  def self.dump(value)
    value.to_s
  end

  def initialize(args)
    FIELDS.each_with_index do |field, index|
      send("#{field}=", args[index] || '')
    end
  end

  def to_s
    FIELDS.reduce([]) { |buffer, field| buffer.push(send(field)); buffer }.join('+')
  end

  def ==(other)
    other.instance_of?(self.class) && to_s == other.to_s
  end

  attr_accessor :uuid,
                :major, :minor,
                :instance, :namespace, :url,
                :protocol
end
