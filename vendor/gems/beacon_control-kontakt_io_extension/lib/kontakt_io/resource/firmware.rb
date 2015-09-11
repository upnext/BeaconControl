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
    class Firmware < Base
      attribute :id,                String
      attribute :important,         Boolean
      attribute :device_type,       String
      attribute :description,       String
      attribute :name,              String
      attribute :valid_versions,    String
      attribute :url,               String

      def latest?
        attributes.any? { |(_,val)| val != nil }
      end

      def valid_versions=(val)
        val = val.split(',') if val.is_a?(String)
        super val
      end
    end
  end
end
