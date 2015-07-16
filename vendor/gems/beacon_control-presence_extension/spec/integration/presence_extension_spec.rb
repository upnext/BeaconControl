###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe 'Presence extension integration', type: :async do
  let!(:application)    { FactoryGirl.create(:application) }
  let!(:user)           { FactoryGirl.create(:user) }
  let!(:mobile_device)  { FactoryGirl.create(:mobile_device, user: user) }

  let!(:account)        { FactoryGirl.create(:account) }
  let!(:beacon)         { FactoryGirl.create(:beacon, account: account) }
  let!(:zone)           { FactoryGirl.create(:zone, account: account) }

  let(:beacon_presence) { BeaconControl::PresenceExtension::BeaconPresence.last }

  before do
    FactoryGirl.create(:application_extension, application: application, extension_name: BeaconControl::PresenceExtension.registered_name)
  end

  before do
    ExtensionsRegistry.add BeaconControl::PresenceExtension
  end

  describe 'storing beacon presence' do
    it 'is possible' do
      expect {
        trigger_event('enter', beacon)
      }.to change(BeaconControl::PresenceExtension::BeaconPresence, :count).by(1)

      expect(BeaconControl::PresenceExtension::BeaconPresence.last.present).to be true
    end

    it 'assigns beacons to an account' do
      trigger_event('enter', beacon)
      expect(account.beacons_and_zones(application.id).map(&:id)).to include(beacon.id)
    end

    describe 'timestamp' do
      before :each do
        trigger_event('enter', beacon)
      end

      it 'updates on next trigger' do
        Timecop.travel(1.minute.from_now) do
          expect {
            trigger_event('enter', beacon)
          }.not_to change(BeaconControl::PresenceExtension::BeaconPresence, :count) and
           change{ beacon_presence.reload.timestamp }
        end
      end

      it 'is updated if valid' do
        Timecop.travel(1.minute.ago) do
          expect {
            trigger_event('enter', beacon)
          }.not_to change{ beacon_presence.reload.timestamp }
        end
      end
    end
  end

  describe 'storing beacon leave' do
    describe 'timestamp' do
      before :each do
        trigger_event('enter', beacon)
      end

      it 'changes present attribute' do
        Timecop.travel(1.minute.from_now) do
          expect {
            trigger_event('leave', beacon)
          }.to change{ beacon_presence.reload.present }.from(true).to(false) and
           change{ beacon_presence.reload.timestamp }
        end
      end

      it 'updates if is valid' do
        Timecop.travel(1.minute.ago) do
          expect {
            trigger_event('leave', beacon)
          }.not_to change{ beacon_presence.reload.timestamp }
        end
      end
    end

    it 'requires enter event before leave event' do
      expect {
        trigger_event('leave', beacon)
      }.not_to change(BeaconControl::PresenceExtension::BeaconPresence, :count)
    end
  end

  describe 'storing incomplete event' do
    it 'is not possible without range' do
      expect {
        trigger_event('enter', OpenStruct.new)
      }.not_to change(BeaconControl::PresenceExtension::BeaconPresence, :count)
    end

    it 'is not possible without event type' do
      expect {
        trigger_event('', beacon)
      }.not_to change(BeaconControl::PresenceExtension::BeaconPresence, :count)
    end
  end

  describe 'storing zone presence' do
    it 'is possible' do
      expect {
        trigger_event('enter', zone)
      }.to change(BeaconControl::PresenceExtension::ZonePresence, :count).by(1)
    end

    it 'assigns zones to an account' do
      trigger_event('enter', zone)
      expect(account.beacons_and_zones(application.id).map(&:id)).to include(zone.id)
    end
  end
end
