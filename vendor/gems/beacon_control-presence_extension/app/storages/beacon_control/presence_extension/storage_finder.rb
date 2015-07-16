###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module PresenceExtension
    class StorageFinder

      #
      # ==== Parameters
      #
      # * +ids+ - Array, list of Beacon / Zone IDs
      #
      def initialize(ids)
        self.ids = Array(ids)
      end

      #
      # For given list of Beacon / Zone IDs, returns list of users currently being present in them.
      #
      # ==== Parameters
      #
      # * +storage_klass+    - +ActiveRecord+ model to run find against. Valid values:
      #   * BeaconPresence
      #   * ZonePresence
      # * +id_column+        - Symbol/String, name of column storing Beacon / Zone ID. Valid values:
      #   * +:beacon_id+
      #   * +:zone_id+
      # * +client_column+    - Symbol/String, name of culumn storing user ID value
      #
      # ==== Returns
      #
      # Hash:
      # * key   => Beacon / Zone ID
      # * value => Array, list of users IDs
      #
      def find_for(storage_klass, id_column, client_column = :client_id)
        found_objects = storage_klass
          .present.for_ids(ids.map(&:to_i))
          .select(id_column, client_column)

        found_objects.each_with_object(presence_hash) do |found_object, hash|
          hash_id = found_object[id_column].to_s

          hash[hash_id] << found_object[client_column]
        end

        presence_hash
      end

      private

      attr_accessor :ids

      #
      # Creates Hash with keys from +self.ids+ and values as empty arrays.
      #
      def presence_hash # :doc:
        @presence_hash ||= Array(ids).each_with_object({}) do |id, hash|
          hash[id.to_s] = []
        end
      end
    end
  end
end
