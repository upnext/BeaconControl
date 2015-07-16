###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::KontaktIoExtension::BeaconsManager do

  let(:current_admin) { FactoryGirl.create(:admin) }
  let(:current_account) { current_admin.account }
  let(:db_beacon_not_matching) { FactoryGirl.create(:beacon,
    account: current_account,
    uuid: "00000000-0000-0000-0000-000000000000",
    major: 0,
    minor: 0
    ) }
  let(:db_beacon_by_proximity) { FactoryGirl.create(:beacon,
    account: current_account,
    uuid: "f7826da6-4fa2-4e98-8024-bc5b71e0893e",
    major: 43277,
    minor: 58568
    ) }
  let(:db_beacon_by_association) { FactoryGirl.create(:beacon,
    account: current_account,
    uuid: "00000000-0000-0000-0000-000000000001",
    major: 0,
    minor: 1,
    beacon_assignment: BeaconControl::KontaktIoExtension::BeaconAssignment.new(unique_id: "9GF3")
    ) }

  let(:manager) { described_class.new(current_admin) }

  let(:kontakt_beacons) {
    JSON.parse(fixture_content('responses/beacons.json'))["beacons"].map { |b|
      KontaktIo::Resource::Beacon.new(b)
    }
  }

  let(:to_import) { manager.to_import(kontakt_beacons) }

  let(:kontakt_beacon_new)            { subject.find{|b| b.unique_id == "IMS2"} }
  let(:kontakt_beacon_by_proximity)   { subject.find{|b| b.unique_id == "0YA4"} }
  let(:kontakt_beacon_by_association) { subject.find{|b| b.unique_id == "9GF3"} }

  before do
    current_account.beacons = [db_beacon_not_matching, db_beacon_by_proximity, db_beacon_by_association]
  end

  context "#to_import" do
    let(:subject) { to_import }

    it "marks beacons present in database" do
      expect(subject.size).to eq(3)

      expect(kontakt_beacon_by_proximity.in_db).to eq(true)
      expect(kontakt_beacon_by_association.in_db).to eq(true)
      expect(kontakt_beacon_new.in_db).to eq(false)
    end

    it "partitions beacons into new/present in database" do
      expect(subject.map &:in_db).to eq([false, true, true])
    end
  end

  context "#import" do
    context "with beacons selected to import" do
      let(:import_beacons) { to_import.map{|b| b.import=true; b} }

      it "creates missing association for matching beacons found in database and new beacons" do
        expect {
          manager.import(import_beacons)
        }.to change(BeaconControl::KontaktIoExtension::BeaconAssignment, :count).by(2)
        expect(db_beacon_by_proximity.reload.beacon_assignment).not_to be_nil
      end

      it "saves new beacons" do
        expect {
          manager.import(import_beacons)
        }.to change(Beacon, :count).by(1)
      end
    end

    context "with none beacons selected to import" do
      it "creates missing association only for matching beacons found in database" do
        expect {
          manager.import(to_import)
        }.to change(BeaconControl::KontaktIoExtension::BeaconAssignment, :count).by(1)
        expect(db_beacon_by_proximity.reload.beacon_assignment).not_to be_nil
      end

      it "not saves new beacons" do
        expect {
          manager.import(to_import)
        }.not_to change(Beacon, :count)
      end
    end
  end

  context "#sync" do
    let(:subject) { kontakt_beacons }

    it "process only beacons matching beacons found in database" do
      expect(manager.sync(kontakt_beacons)).not_to include(kontakt_beacon_new)
      expect(manager.sync(kontakt_beacons)).to include(kontakt_beacon_by_proximity)
      expect(manager.sync(kontakt_beacons)).to include(kontakt_beacon_by_association)
    end

    it "associates matching beacons" do
      expect {
        manager.sync(kontakt_beacons)
      }.to change(BeaconControl::KontaktIoExtension::BeaconAssignment, :count).by(1)
      expect(db_beacon_by_proximity.reload.beacon_assignment).not_to be_nil
    end

    it "updates already associated beacons data" do
      expect {
        manager.sync(kontakt_beacons)
        db_beacon_by_association.reload
      }.to change(db_beacon_by_association, :uuid) and
           change(db_beacon_by_association, :major) and
           change(db_beacon_by_association, :minor)
    end
  end
end
