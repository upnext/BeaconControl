###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 's2s_api/v1/trigger_serializer' unless defined? S2sApi::V1::TriggerSerializer

module S2sApi
  module V1
    class TriggerSerializer
      module DwellTime
        extend ActiveSupport::Concern

        included do
          attributes :dwell_time
        end
      end
    end
  end
end
