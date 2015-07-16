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
    # Kontakt.io Manager object
    #
    class Manager < Base
      attribute :id,            String
      attribute :unique_id,     String
      attribute :supervisor_id, String
      attribute :first_name,    String
      attribute :last_name,     String
      attribute :email,         String
      attribute :role,          String
      attribute :devices_count, Integer

      def name
        "#{first_name} #{last_name}"
      end
    end
  end
end
