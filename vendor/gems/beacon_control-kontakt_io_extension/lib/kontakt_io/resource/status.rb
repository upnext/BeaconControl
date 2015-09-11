###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module KontaktIo
  module Resource

    #
    # Kontakt.io Beacon object
    #
    class Status < Base
      attribute :battery_level,         Integer
      attribute :avg_event_interval,    Integer
      attribute :last_event_timestamp,  Integer
      attribute :slaves,                Array
      attribute :master,                String
    end
  end
end
