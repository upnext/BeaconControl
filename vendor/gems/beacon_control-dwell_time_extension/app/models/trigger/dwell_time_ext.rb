###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'trigger' unless defined? Trigger

module Trigger::DwellTimeExt
  extend ActiveSupport::Concern

  included do
    DWELL_TIME = OpenStruct.new(default: 5, min: 5, max: 60, step: 1)

    validates :dwell_time, inclusion: { in: Trigger::DWELL_TIME.min..Trigger::DWELL_TIME.max },
              numericality: { only_integer: true },
              allow_blank: true

    after_initialize :set_default_dwell_time

    private

    def set_default_dwell_time
      self.dwell_time ||= Trigger::DWELL_TIME.default
    end
  end
end
