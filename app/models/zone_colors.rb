###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ZoneColors
  class ZoneColor
    attr_reader :color

    def initialize(color)
      self.color = color
    end

    private

    attr_writer :color
  end

  attr_reader :colors

  def initialize(*path)
    file = YAML.load_file(Rails.root.join(*path))

    @colors = file['colors'].map {|c| ZoneColor.new(c) }
  end

  def sample
    @colors.sample.color
  end

  class << self
    def list
      @list ||= ZoneColors.new('config', 'colors.yml')
    end

    def to_a
      list.colors.map(&:color)
    end

    def to_json
      to_a.in_groups_of(4).to_json
    end

    def sample
      to_a.sample
    end

    def insensitive_matcher
      Regexp.new ZoneColors.to_a.join('|'), 'i'
    end
  end
end
