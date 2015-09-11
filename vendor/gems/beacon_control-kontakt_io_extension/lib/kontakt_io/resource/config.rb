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
    class Config < Base
      attribute :proximity,   String
      attribute :interval,    String
      attribute :minor,       Integer
      attribute :major,       Integer
      attribute :tx_power,    Integer
      attribute :name,        String
      attribute :password,    String
      attribute :unique_id,   String
    end
  end
end
