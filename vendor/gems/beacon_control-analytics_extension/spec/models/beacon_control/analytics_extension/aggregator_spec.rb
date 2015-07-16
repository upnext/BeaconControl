###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::AnalyticsExtension::Aggregator do
  let(:application) { FactoryGirl.create(:application) }
  let(:beacon)      { FactoryGirl.create(:beacon) }
  let(:zone)        { FactoryGirl.create(:zone) }

  let(:event_type) { }
  let(:timestamp)  { 4000 }
  let(:with_zone?) { false }

  let(:event) do
    double(
      client_id:    'foo',
      beacon:        beacon,
      zone:          zone,
      proximity_id:  'bar',
      application:   application,
      event_type:    event_type,
      timestamp:     timestamp,
      action_id:     nil,
      with_zone?:    with_zone?
    )
  end

  let(:aggregator) { described_class.new(event) }

  describe 'on enter' do
    let(:event_type) { 'enter' }
    let(:db_event) { BeaconControl::AnalyticsExtension::Event.last }

    before do
      expect { aggregator.aggregate }.to change(BeaconControl::AnalyticsExtension::Event, :count).by(1)
    end

    describe 'beacon' do
      it 'creates Event' do
        expect(db_event.beacons).to include(beacon)
        expect(db_event.zones).not_to include(zone)
      end
    end

    describe 'zone' do
      let(:with_zone?) { true }

      it 'creates Event' do
        expect(db_event.beacons).not_to include(beacon)
        expect(db_event.zones).to include(zone)
      end
    end
  end

  describe 'on leave' do
    let(:event_type) { 'leave' }
    let(:timestamp)  { 5000 }

    before do
      BeaconControl::AnalyticsExtension::Event.create(
        application_id: application.id,
        proximity_id: 'bar',
        event_type: 'enter',
        user_id: 'foo',
        timestamp: Time.at(4000),
        action_id: nil
      )
    end

    it' creates leave Event' do
      expect { aggregator.aggregate }.to change(BeaconControl::AnalyticsExtension::Event, :count).by(1)
    end

    it 'aggregates dwell time' do
      expect { aggregator.aggregate }.to change(BeaconControl::AnalyticsExtension::DwellTimeAggregation, :count).by(1)
    end

    describe 'long running event' do
      let(:timestamp) { 3.days.seconds }

      it 'creates dwell time aggregation for each day in range' do
        expect { aggregator.aggregate }.to change(BeaconControl::AnalyticsExtension::DwellTimeAggregation, :count).by(4)
      end

      it 'calculates correctly dwell time' do
        aggregator.aggregate

        dwell_time_aggregations = BeaconControl::AnalyticsExtension::DwellTimeAggregation.order(:date)
        expect(dwell_time_aggregations[1].dwell_time).to eq(1.day)
        expect(dwell_time_aggregations[2].dwell_time).to eq(1.day)
        expect(dwell_time_aggregations[3].dwell_time).to eq(1.hour)
      end
    end
  end
end
