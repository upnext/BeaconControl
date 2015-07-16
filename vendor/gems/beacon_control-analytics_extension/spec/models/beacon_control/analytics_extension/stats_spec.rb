###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::AnalyticsExtension::Stats do
  let(:application) { FactoryGirl.create(:application) }

  let(:event) do
    {
      application:   application,
      proximity_id:  'bar',
      user_id:       'foo',
      event_type:    'enter',
      action_id:     1
    }
  end

  let(:dwell_time_aggregation) do
    {
      application:  application,
      proximity_id: 'foo',
      user_id:      'bar'
    }
  end

  before do
    (1..3).each do |i|
      FactoryGirl.create_list(:event, i, event.merge(timestamp: Time.now - i.days))
    end
  end

  describe '#action_count' do
    let(:action_count) { described_class.action_count(application.id) }
    let(:history_limit) { BeaconControl::AnalyticsExtension::Stats::DEFAULT_LIMIT }

    it 'calculates number of actions per day' do
      (1..3).each do |i|
        expect(action_count[Date.today - i.days]).to eq(i)
      end
    end

    it 'creates N+1 days history' do
      (0..history_limit).each do |i|
        expect(action_count).to have_key(Date.today - i.days)
      end

      expect(action_count.keys.size).to eq(history_limit + 1)
    end
  end

  describe '#unique_users' do
    let(:unique_users) { described_class.unique_users(application.id) }

    it 'counts user events uniquely' do
      (1..3).each do |i|
        expect(unique_users[Date.today - i.days]).to eq(1)
      end
    end
  end

  describe '#dwell_time' do
    let(:dwell_time) { described_class.dwell_time(application.id) }

    before do
      (1..3).each do |i|
        FactoryGirl.create_list(:dwell_time_aggregation, i, dwell_time_aggregation.merge(
          date: Date.today - i.days,
          timestamp: Time.now - i.days,
          dwell_time: 10
        ))
      end
    end

    it 'calculates summary dwell time per day' do
      (1..3).each do |i|
        expect(dwell_time[Date.today - i.days]).to eq(i * 10)
      end
    end
  end
end
