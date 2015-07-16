###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe 'Analytics extension integration', type: :async do
  let(:application)   { FactoryGirl.create(:application) }
  let(:user)          { FactoryGirl.create(:user) }
  let(:mobile_device) { FactoryGirl.create(:mobile_device, user: user) }

  let(:beacon)  { FactoryGirl.create(:beacon) }

  let(:stats) { BeaconControl::AnalyticsExtension::Stats }

  before do
    FactoryGirl.create(:application_extension, application: application, extension_name: BeaconControl::AnalyticsExtension.registered_name)
    ExtensionsRegistry.add BeaconControl::AnalyticsExtension
  end

  describe 'entering beacon range' do
    it 'increases number of actions' do
      3.times do
        expect { trigger_event }.to change{ stats.action_count(application.id)[Date.today] }.by(1)
      end

      expect(stats.action_count(application.id)[Date.today]).to eq(3)
    end

    it 'increases number of active users' do
      expect { trigger_event }.to change{ stats.unique_users(application.id)[Date.today] }.by(1)
    end

    it 'counts users uniquely' do
      trigger_event
      3.times do
        expect { trigger_event }.not_to change{ stats.unique_users(application.id)[Date.today] }
      end
    end

    describe 'grupus numbers by days' do
      subject { lambda {
        3.times do |i|
          Timecop.travel(Time.now - i.days) do
            trigger_event
          end
        end
       } }

      it { should change{ stats.action_count(application.id)[Date.today]}.by(1) }

      it { should change{ stats.action_count(application.id)[Date.today - 1.day]}.by(1) }

      it { should change{ stats.action_count(application.id)[Date.today - 2.days]}.by(1) }

      it { should_not change{ stats.action_count(application.id)[Date.today - 3.days]} }
    end
  end

  describe 'leaving beacon range' do
    it 'calculates dwell time' do
      trigger_event
      Timecop.travel(Time.now + 1.hour) do
        trigger_event('leave')
      end

      expect(stats.dwell_time(application.id)[Date.today]).to eq(1.hour)
    end

    it 'recalculates dwell time if multiple enter-leave events occurs' do
      trigger_event

      Timecop.travel(Time.now + 1.hour) do
        trigger_event('leave')
      end
      Timecop.travel(Time.now + 2.hour) do
        trigger_event('enter')
      end
      Timecop.travel(Time.now + 3.hour) do
        trigger_event('leave')
      end

      expect(stats.dwell_time(application.id)[Date.today]).to eq(2.hours)
    end

    it 'ignores newer leave events' do
      trigger_event

      [1,2].each do |i|
        Timecop.travel(Time.now + i.hour) do
          trigger_event('leave')
        end
      end
      expect(stats.dwell_time(application.id)[Date.today]).to eq(1.hours)
    end

    it 'calculates dwell time based on last enter event' do
      trigger_event
      Timecop.travel(Time.now + 1.hour) do
        trigger_event
      end
      Timecop.travel(Time.now + 2.hour) do
        trigger_event('leave')
      end

      expect(stats.dwell_time(application.id)[Date.today]).to eq(1.hour)
    end

    it 'requires enter event' do
      Timecop.travel(Time.now + 1.hour) do
        trigger_event('leave')
      end

      expect(stats.dwell_time(application.id)[Date.today]).to eq(0)
    end
  end
end
