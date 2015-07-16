###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe KontaktIo::Resource::Beacon do
  let(:attributes) {
    {
      unique_id: unique_id,
      proximity: proximity,
      major:     major,
      minor:     minor
    }
  }
  let(:major) { 0 }
  let(:minor) { 0 }
  let(:proximity) { "00000000-0000-0000-0000-000000000000" }
  let(:unique_id) { "AA00" }
  let(:kontakt_beacon) { described_class.new(attributes) }

  let(:db_beacon) {
    Beacon.new(
      uuid: "00000000-0000-0000-0000-000000000000",
      major: 0,
      minor: 0,
      beacon_assignment: BeaconControl::KontaktIoExtension::BeaconAssignment.new(unique_id: "AA00")
    )
  }

  describe "#proximity_id" do
    it "is composed properly" do
      expect(kontakt_beacon.proximity_id).to eq("00000000-0000-0000-0000-000000000000+0+0")
    end
  end

  describe '#==' do
    let(:subject) { kontakt_beacon == db_beacon }

    context 'with major,minor,proximity different' do
      let(:major) { 1 }
      let(:minor) { 1 }
      let(:proximity) { "00000000-0000-0000-0000-000000000001" }

      context 'with unique_id equal' do
        let(:unique_id) { "AA00" }
        it { should be(true) }
      end

      context 'with unique_id different' do
        let(:unique_id) { "AA11" }
        it { should be(false) }
      end
    end

    context 'with proximity_id different' do
      let(:unique_id) { "AA11" }

      context 'with major,minor,proximity equal' do
        it { should be(true) }
      end

      context 'with major different' do
        let(:major) { 1 }
        it { should be(false) }
      end

      context 'with minor different' do
        let(:minor) { 1 }
        it { should be(false) }
      end

      context 'with proximity different' do
        let(:proximity) { "00000000-0000-0000-0000-000000000001" }
        it { should be(false) }
      end
    end
  end
end
