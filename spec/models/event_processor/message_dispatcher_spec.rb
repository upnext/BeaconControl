###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe EventProcessor::MessageDispatcher do
  let(:application) { FactoryGirl.create(:application) }
  let(:user)        { FactoryGirl.create(:user) }
  let(:mobile_device) { FactoryGirl.create(:mobile_device, user: user) }

  let!(:extension) do
    ExtensionsRegistry.add FooExtension
  end

  before do
    FactoryGirl.create(:application_extension, application: application, extension_name: 'Foo')
  end

  let(:params) do
    {
      events:        events,
      application:   application,
      user:          user,
      mobile_device: mobile_device
    }
  end

  let(:message) { EventProcessor::Message.new(params) }

  let(:dispatcher) { double(dispatch: true) }

  describe 'dispatch' do
    before { allow_any_instance_of(FooExtension::Worker).to receive(:publish) }

    context 'when application exists' do
      let(:beacon)  { FactoryGirl.create(:beacon) }
      let(:zone)    { FactoryGirl.create(:zone) }
      let(:trigger) { FactoryGirl.create(:trigger, beacons: [beacon], zones: [zone], application: application) }
      let(:events)  { [ event ] }
      let(:event)   { {} }

      context 'when there is an appropriate activity for event' do
        let(:activity) { FactoryGirl.create(:url_activity, trigger: trigger) }
        let(:event) do
          {
            action_id: activity.id,
            range_id: beacon.id
          }
        end

        let(:published_event) do
          EventProcessor::Message::Event.new(
            event.merge(
              application:   application,
              event_type:    activity.trigger.event_type,
              proximity_id:  beacon.proximity_id.to_s,
              action:        activity,
              user:          user,
              mobile_device: mobile_device
            )
          )
        end

        it 'pushes proper message to EventProcessor::EventDispatcher' do
          expect(EventProcessor::EventDispatcher).to receive(:new).with(
            event:      published_event,
            extensions: [extension]
          ).and_return(dispatcher)

          described_class.new(message).dispatch
        end
      end

      context 'when there is no appropriate activity for event and event type is present in event hash' do
        let(:event) do
          {
            action_id: 'fafa',
            range_id: beacon.id,
            event_type: 'enter'
          }
        end

        let(:published_event) do
          EventProcessor::Message::Event.new(
            event.merge(
              application:   application,
              event_type:    event[:event_type],
              proximity_id:  beacon.proximity_id.to_s,
              user:          user,
              mobile_device: mobile_device
            )
          )
        end

        it 'pushes proper message to EventProcessor::EventDispatcher' do
          expect(EventProcessor::EventDispatcher).to receive(:new).with(
            event:      published_event,
            extensions: [extension]
          ).and_return(dispatcher)

          described_class.new(message).dispatch
        end
      end

      context 'when event contains zone instead of range' do
        let(:activity) { FactoryGirl.create(:url_activity, trigger: trigger) }
        let(:event) do
          {
            action_id: activity.id,
            zone_id: zone.id
          }
        end

        let(:published_event) do
          EventProcessor::Message::Event.new(
            event.merge(
              application:   application,
              event_type:    activity.trigger.event_type,
              zone_id:       zone.id,
              action:        activity,
              user:          user,
              mobile_device: mobile_device
            )
          )
        end

        it 'pushes proper message to EventProcessor::EventDispatcher' do
          expect(EventProcessor::EventDispatcher).to receive(:new).with(
            event:      published_event,
            extensions: [extension]
          ).and_return(dispatcher)

          described_class.new(message).dispatch
        end
      end

      context 'when there is no appropriate activity for event and event type is not present in event hash' do
        let(:event) do
          {
            action_id: 'fafa',
            range_id: beacon.id
          }
        end

        it 'skips the event' do
          expect(extension).not_to receive(:publish)
        end
      end

      context 'when beacon nor zone are not found' do
        let(:event) do
          {
            range_id: 'foobar-123',
            event_type: 'enter'
          }
        end

        it 'skips the event' do
          expect(extension).not_to receive(:publish)
        end
      end
    end
  end
end
