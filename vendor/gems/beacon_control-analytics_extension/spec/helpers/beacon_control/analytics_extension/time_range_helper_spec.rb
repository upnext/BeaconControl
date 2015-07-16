###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::AnalyticsExtension::TimeRange, type: :model do

  let(:start_time) { Date.today.beginning_of_day }
  let(:end_time) { start_time }

  let(:timestamps) { described_class.new(start_time, end_time).split_to_days }

  describe '#split_to_days' do
    describe 'with same times' do
      it 'creates 2 timestamps range' do
        expect(timestamps.size).to eq(2)
      end
    end

    describe 'with > 0 time range' do
      let(:days) { 5 }
      let(:end_time) { start_time + days.days }

      it 'creates N+2 timestamps' do
        expect(timestamps.size).to eq(days + 2)
      end

      it 'creates timestamps within requested range' do
        expect(Time.at(timestamps.min)).to be >= start_time
        expect(Time.at(timestamps.max)).to be <= end_time
      end
    end
  end
end
