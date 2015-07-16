###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class BeaconFilterForm
  UNASSIGNED_ZONE = Zone.new(name: I18n.t('beacons.index.unassigned_zone'), color: '494846').freeze

  def initialize(account, ability)
    self.account = account
    self.ability = ability
  end

  def floors
    all_floors + BeaconDecorator.floors_for_select(['null',I18n.t('beacons.index.unassigned_floor')], true)
  end

  def zones
    @zones ||= [UNASSIGNED_ZONE] | account.zones.accessible_by(ability)
  end

  private

  def all_floors
    [[I18n.t('beacons.index.all_floors'), 'all']]
  end

  attr_accessor :account, :ability
end
