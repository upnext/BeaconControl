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

  #
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
    if value
      new(*value.split(/\+/, 3))
    else
      new
    end
  end

  def self.dump(value)
    value.to_s
  end

  def initialize(uuid = nil, major = nil, minor = nil)
    self.uuid = uuid
    self.major = major
    self.minor = minor
  end

  def to_s
    "#{uuid}+#{major}+#{minor}"
  end

  def ==(other)
    other.instance_of?(self.class) && to_s == other.to_s
  end

  attr_accessor :uuid, :major, :minor
end
