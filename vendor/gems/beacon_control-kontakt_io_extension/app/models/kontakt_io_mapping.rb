class KontaktIoMapping < ActiveRecord::Base
  self.table_name = 'ext_kontakt_io_mapping'
  belongs_to :target,
             polymorphic: true

  validates :kontakt_uid,
            presence: true

  scope :zones, ->{ where(target_type: :Zone) }
  scope :beacons, ->{ where(target_type: :Beacon) }

  scope :with_uid, ->(uid=nil) do
    uid ? where(kontakt_uid: uid) : where('kontakt_uid IS NOT NULL')
  end

  def self.imported_uids(list)
    where(kontakt_uid: list).pluck(:kontakt_uid)
  end

  def self.not_imported_uids(list)
    list - imported_uids(list)
  end
end