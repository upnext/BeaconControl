###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'beacon' unless defined? Beacon

class Beacon
  module KontaktIoExtension
    module Extension
      extend ActiveSupport::Concern
      included do
        has_one :beacon_assignment,
                class_name: BeaconControl::KontaktIoExtension::BeaconAssignment,
                dependent: :destroy

        has_one :kontakt_io_mapping,
                ->{ where(target_type: :Beacon) },
                as: :target,
                dependent: :destroy

        delegate :kontakt_uid,
                 to: :kontakt_io_mapping,
                 allow_nil: true

        alias_attribute :unique_id, :kontakt_uid

        def kontakt_io_imported?
          kontakt_io_mapping.present?
        end

        unless method_defined?(:_non_kontakt_io_imported?)
          alias_method :_non_kontakt_io_imported?, :imported?
        end

        def imported?
          kontakt_io_imported? || _non_kontakt_io_imported?
        end

        scope :kontakt_io, -> { joins(:kontakt_io_mapping).merge(KontaktIoMapping.beacons) }
      end
    end
  end
end
