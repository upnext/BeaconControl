###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module KontaktIoExtension

    #
    # Stores Beacon Control - KontaktIo beacon connection.
    #
    class BeaconAssignment < ActiveRecord::Base
      belongs_to :beacon

      validates :unique_id, presence: true
    end
  end
end
