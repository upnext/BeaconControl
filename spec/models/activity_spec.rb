###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe Activity do
  describe '#notification_for_device' do
    let!(:activity) { described_class.create(name: 'Foo', scheme: 'url') }

    let(:token) { 'token' }

    let(:mobile_device) { double(push_token: token, os: os) }

    let(:notification) { activity.notification_for_device(mobile_device) }

    context 'android' do
      let(:os) { 'android' }

      it 'returns gcm notification' do
        expect(notification).to be_instance_of(Rpush::Gcm::Notification)

        expect(notification.registration_ids).to eq(['token'])
        expect(notification.data).to eq({
          'alert'     => activity.name,
          'action_id' => activity.id
        })
      end
    end

    context 'ios' do
      let(:os) { 'ios' }

      it 'returns apns notification' do
        expect(notification).to be_instance_of(Rpush::Apns::Notification)

        expect(notification.device_token).to eq(token)
        expect(notification.alert).to eq(activity.name)
        expect(notification.data).to eq({ 'action_id' => activity.id })
      end
    end

    context 'undefined' do
      let(:os) { 'foobar' }

      it 'returns stub notification' do
        expect(notification).to be_instance_of(Activity::Notification::Null)
      end
    end
  end

  describe "#url=(value)" do
    let(:url) { 'http://www.google.pl' }
    let(:url_without_scheme) { 'www.google.pl' }

    it "sets payload while url setting" do
      activity = Activity.new(url: url)
      expect(activity.payload).to eq(url: url)
    end

    it "prepends http scheme when url doesn't have one" do
      activity = Activity.new(url: url_without_scheme)
      expect(activity.payload).to eq(url: url)
    end
  end
end
