###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe 'EventProcessor event processing', type: :async do
  let!(:application)   { FactoryGirl.create(:application) }
  let!(:user)          { FactoryGirl.create(:user) }
  let!(:mobile_device) { FactoryGirl.create(:mobile_device, user: user) }

  let!(:beacon)  { FactoryGirl.create(:beacon) }
  let!(:trigger) { FactoryGirl.create(:trigger, beacons: [beacon], application: application) }

  let!(:app_ext) { FactoryGirl.create(:application_extension, application: application, extension_name: 'Foo') }

  let!(:extension) { ExtensionsRegistry.add FooExtension }

  let!(:event) do
    {
      event_type: 'enter',
      range_id: beacon.id
    }
  end

  let(:ep_message) do
    {
      events:        [event],
      application:   application,
      user:          user,
      mobile_device: mobile_device,
    }
  end

  it 'forwards events to enabled extensions' do
    application.reload

    expect(FooExtension::Worker).to receive(:new).with(
      EventProcessor::Message::Event.new(
        ep_message.merge(event).merge(proximity_id: beacon.proximity_id.to_s)
      )
    ).and_call_original

    perform_enqueued_jobs do
      EventProcessor.process(ep_message)
    end
  end
end
