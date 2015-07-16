###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::DwellTimeExtension::EnterEvent, type: :async do
  let(:store) { Moneta.new(:Redis) }

  let(:application) { FactoryGirl.create(:application) }

  let(:beacon) { double(triggers_for_application: triggers) }
  let(:event) do
    double(
      mobile_device: FactoryGirl.create(:mobile_device),
      proximity_id:  'bar',
      beacon:        beacon,
      application:   application,
      timestamp:     3100
    )
  end

  let(:activity) { FactoryGirl.create(:activity) }

  let(:triggers) do
    [
      double(id: 1, dwell_time: 1, activity: activity),
      double(id: 2, dwell_time: 3, activity: activity),
    ]
  end

  let(:trigger_ids) do
    [
      BeaconControl::DwellTimeExtension::Identifier.new(event, triggers[0].id).to_s,
      BeaconControl::DwellTimeExtension::Identifier.new(event, triggers[1].id).to_s
    ]
  end

  let(:sidekiq_id_1) { double(sidekiq_id: 'foo') }
  let(:sidekiq_id_2) { double(sidekiq_id: 'bar') }

  before do
    allow(application).to receive(:rpush_app_for_device) { "foo" }
  end

  it 'creates notify job for every trigger in Sidekiq' do
    described_class.new(event, store).call

    expect(enqueued_jobs.size).to eq(2)
  end

  it 'saves job references in store' do
    allow(BeaconControl::DwellTimeExtension::NotifierJob).to receive(:after).and_return(sidekiq_id_1, sidekiq_id_2)

    described_class.new(event, store).call

    expect(store[trigger_ids[0]]).to eq('foo')
    expect(store[trigger_ids[1]]).to eq('bar')
  end
end
