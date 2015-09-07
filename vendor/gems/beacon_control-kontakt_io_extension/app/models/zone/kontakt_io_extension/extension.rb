require 'zone' unless defined? Zone

class Zone
  module KontaktIoExtension
    module Extension
      extend ActiveSupport::Concern


      included do
        has_one :kontakt_io_mapping,
                ->{ where(target_type: :Zone) },
                as: :target,
                autosave: true,
                dependent: :destroy

        delegate :kontakt_uid, to: :kontakt_io_mapping

        def kontakt_io_imported?
          kontakt_io_mapping.present?
        end

        scope :kontakt_io, -> { joins(:kontakt_io_mapping).merge(KontaktIoMapping.zones) }

        scope :with_kontakt_uid, ->(uid) { kontakt_io.merge(KontaktIoMapping.with_uid(uid)) }
      end
    end
  end
end
