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

        after_save do
          if self.vendor == 'Kontakt'
            (kontakt_io_mapping || build_kontakt_io_mapping).save
          end
        end

        unless method_defined?(:kontakt_extended)
          attr_reader :kontakt_extended
          alias_method :_non_kontakt_io_imported?, :imported?
          alias_method :_non_kontakt_io_vendor_uid, :vendor_uid
          alias_method :_non_kontakt_io_vendor_uid=, :vendor_uid=
        end

        scope :kontakt_io, -> { joins(:kontakt_io_mapping).merge(KontaktIoMapping.beacons) }

        async_value :uuid,
                    config_key: :proximity,
                    beacon: -> { self },
                    vendor: :Kontakt,
                    cast: 'to_s.upcase'
        async_value :minor,
                    config_key: :minor,
                    beacon: -> { self },
                    vendor: :Kontakt
        async_value :major,
                    config_key: :major,
                    beacon: -> { self },
                    vendor: :Kontakt
        async_value :namespace,
                    config_key: :namespace,
                    beacon: -> { self },
                    vendor: :Kontakt,
                    cast: 'to_s.upcase'
        async_value :instance,
                    config_key: :instance_id,
                    beacon: -> { self },
                    vendor: :Kontakt,
                    cast: 'to_s.upcase'
        async_value :url,
                    config_key: :url,
                    beacon: -> { self },
                    vendor: :Kontakt,
                    cast: 'to_s.upcase'

        delegate :current_signal_interval,
                 :signal_interval,
                 :signal_interval=,
                 :signal_interval_changed?,
                 :current_transmission_power,
                 :transmission_power,
                 :transmission_power=,
                 :transmission_power_changed?,
                 to: :config

        def kontakt_io_imported?
          kontakt_io_mapping.present?
        end

        def imported?
          kontakt_io_imported? || _non_kontakt_io_imported?
        end

        def vendor_uid
          self.vendor == 'Kontakt' ? self.kontakt_uid : self._non_kontakt_io_vendor_uid
        end

        def vendor_uid=(val)
          if self.vendor == 'Kontakt'
            m = kontakt_io_mapping || build_kontakt_io_mapping
            m.kontakt_uid = val
          else
            self._non_kontakt_io_vendor_uid = val
          end
        end

        def kontakt_io_sync!(admin)
          sync = ::BeaconControl::KontaktIoExtension::MappingService.new(admin)
          sync.sync!(update: true, beacons: [kontakt_uid], reassign: false) if kontakt_uid.present?
        end
      end
    end
  end
end
