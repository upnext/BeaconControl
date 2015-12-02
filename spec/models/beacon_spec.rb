###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

require 'rails_helper'

RSpec.describe Beacon do
  describe 'validation' do
    let(:account) { FactoryGirl.create(:account) }
    let(:subject) { build(:beacon, manager: manager) }
    let(:beacon) { create(:beacon, account: account) }

    context 'manger' do
      context 'with admin role' do
        let(:manager) { FactoryGirl.create(:admin, role: 'admin', account: account) }
        it { should_not be_valid }
      end

      context 'with beacon_manager role' do
        let(:manager) { FactoryGirl.create(:admin, role: 'beacon_manager', account: account) }
        it { should be_valid }
      end
    end

    it 'does not allow to create same beacons on the same accounts' do
      another_beacon = build(:beacon, account: account, uuid: beacon.uuid, major: beacon.major, minor: beacon.minor)
      expect(another_beacon).to_not be_valid
    end

    it 'allows to create same beacons on seperate accounts' do
      another_account = create(:account)
      another_beacon = build(:beacon, account: another_account)
      expect(another_beacon).to be_valid
    end
  end

  describe '.search' do
    before { [
      create(:beacon, name: 'Beacon 1', floor: 8, zone: create(:zone, name: 'B')),
      create(:beacon, name: 'Beacon 2', floor: 3, zone: create(:zone, name: 'C')),
      create(:beacon, name: 'Foo', floor: 5, zone: create(:zone, name: 'A'))
    ] }

    it 'returns only records starting with Beacon' do
      expect(Beacon.with_name('Beacon').size).to eq(2)
    end

    it 'returns all records when query in null' do
      expect(Beacon.all.count).to eq(3)
    end

    it 'orders records by floor descending' do
      result = Beacon.sorted('floor', 'desc')
      expect(result.map(&:floor)).to eq [8, 5, 3]
    end

    it 'orders records by zones.name ascending' do
      result = Beacon.includes(:zone).joins(:zone).sorted('zones.name', 'asc')
      expect(result.map { |i| i.zone.name }).to eq ['A', 'B', 'C']
    end

    it 'orders records by zones.name descending together with beacon name search' do
      result = Beacon.includes(:zone).joins(:zone).with_name('Beacon').sorted('zones.name', 'desc')
      expect(result.map { |i| i.zone.name }).to eq ['C', 'B']
    end
  end
end
