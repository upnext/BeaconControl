###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::PresenceExtension::Storage do
  let(:beacon)      { FactoryGirl.create(:beacon) }
  let(:zone)        { FactoryGirl.create(:zone) }
  let(:account)     { FactoryGirl.create(:account, beacons: [beacon], zones: [zone]) }
  let(:application) { FactoryGirl.create(:application, account: account) }

  before do
    BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon("bp-client", beacon.id).create
    BeaconControl::PresenceExtension::ZonePresence.present.for_user_and_zone("zp-client", zone.id).create
  end

  describe "#get_status" do
    context "returns users in aplication's beacons ranges and zones" do
      let(:subject){ described_class.get_status(application, {}) }

      it { should have_key(:ranges) }
      it { should have_key(:zones) }
      it { should include(ranges: {beacon.id.to_s => ["bp-client"]}) }
      it { should include(zones: {zone.id.to_s => ["zp-client"]}) }
    end

    context "returns users filtered by ranges and zones" do
      let(:subject){ described_class.get_status(application, {ranges: [beacon.id], zones: nil}) }

      it { should have_key(:ranges) }
      it { should_not have_key(:zones) }
      it { should include(ranges: {beacon.id.to_s => ["bp-client"]}) }
    end

    context "returns only present users" do
      let(:subject){ described_class.get_status(application, {}) }

      before do
        BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon("bp-client-2", beacon.id).create
        BeaconControl::PresenceExtension::BeaconPresence.for_user_and_beacon("bp-client-3", beacon.id).create
      end

      it { should include(ranges: {beacon.id.to_s => ["bp-client", "bp-client-2"]}) }
    end

    context "returns only given application ranges & zones" do
      let(:other_beacon)      { FactoryGirl.create(:beacon) }
      let(:other_account)     { FactoryGirl.create(:account, beacons: [other_beacon]) }
      let(:other_application) { FactoryGirl.create(:application, account: other_account) }
      let(:subject) { described_class.get_status(application, {})[:ranges] }

      before do
        BeaconControl::PresenceExtension::BeaconPresence.present.for_user_and_beacon("bp-client-4", other_beacon.id).create
      end

      it { should_not have_key(other_beacon.id.to_s) }
    end
  end
end
