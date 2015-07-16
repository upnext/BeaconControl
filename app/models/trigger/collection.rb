###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Trigger
  class Collection
    class << self

      #
      # For given range type, returns list of valid triggers.
      #
      # ==== Parameters
      #
      # * +application+  - Application instance to return valid trigger types for
      # * +trigger_type+ - type of range, valid values:
      #   * +BeaconTrigger+
      #   * +ZoneTrigger+
      #
      def list(application, trigger_type="BeaconTrigger")
        types = case trigger_type
                when "ZoneTrigger" then ZONE_SUPPORTED_TYPES
                when "BeaconTrigger" then BEACON_SUPPORTED_TYPES
                else []
                end
        types += Trigger.extensions_types(application)

        @list = types.uniq.each_with_object([]) do |type, obj|
          obj << OpenStruct.new(
            type: type,
            name: I18n.t("triggers.#{type}"),
            description: I18n.t("triggers.#{type}_description")
          )
        end
      end

      #
      # Returns list of Trigger types, as +OpenStruct+ object.
      #
      def source_types
        @types ||= ["BeaconTrigger", "ZoneTrigger"].each_with_object([]) do |type, obj|
          obj << OpenStruct.new(type: type, name: I18n.t("triggers.range.#{type}"))
        end
      end
    end
  end
end
