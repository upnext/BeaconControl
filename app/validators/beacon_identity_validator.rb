class BeaconIdentityValidator < ActiveModel::Validator
  attr_reader :chain

  def initialize(*)
    super
    # @type [Lambda[]]
    @chain = [
    ->(r){ validate_proximity_id!(r) },
    ->(r){ validate_i_beacon(r) },
    ->(r){ validate_eddystone(r) }
    ]
  end

  def validate(record)
    chain.each do |step|
      step.call record
    end
    record.errors.empty?
  end

  def proximity_id?(record)
    record.proximity_id.present?
  end

  def proximity_exists?(record)
    scope = Beacon.where(
      proximity_uuid: record.proximity_uuid,
      account_id: record.account_id
    )
    scope = scope.where('id != ?', record.id) if record.persisted?
    scope.exists?
  end

  def validate_proximity_id!(record)
    unless proximity_id?(record)
      return record.errors.add(:proximity_id, 'is missing')
    end
    if proximity_exists?(record)
      return record.errors.add(:proximity_id, 'is not unique')
    end
    true
  end

  def validate_i_beacon(record)
    return unless record.protocol == 'iBeacon'
    validate_uuid(record)

    record.errors.add(:major, 'is missing') unless record.major.present?
    record.errors.add(:major, 'must be number') unless record.major.to_s.match /^\d+$/

    record.errors.add(:minor, 'is missing') unless record.minor.present?
    record.errors.add(:minor, 'must be number') unless record.minor.to_s.match /^\d+$/
  end

  def validate_eddystone(record)
    return unless record.protocol == 'Eddystone'
    record.errors.add(:namespace, 'is missing') unless record.namespace.present?
    record.errors.add(:instance, 'is missing') unless record.instance.present?
  end

  def validate_uuid(record)
    record.uuid.to_s.upcase!
    uuid = record.uuid
    return if uuid.blank?
    record.errors.add(:uuid, "must match #{UuidFormat::REGEX}") unless UuidFormat::REGEX =~ uuid
  end
end