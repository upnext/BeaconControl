###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe 'DwellTime extension integration', type: :async do
  let!(:application) { FactoryGirl.create(:application) }
  let!(:user)        { FactoryGirl.create(:user) }
  let!(:mobile_device) do
    FactoryGirl.create(:mobile_device, {
      user:        user,
      push_token: 'FE66489F304DC75B8D6E8200DFF8A456E8DAEACEC428B427E9518741C92C6660',
      environment: 'sandbox'
    })
  end

  let!(:beacon)  { FactoryGirl.create(:beacon) }
  let!(:zone)  { FactoryGirl.create(:zone) }

  before do
    ExtensionsRegistry.add(BeaconControl::DwellTimeExtension)
    FactoryGirl.create(:application_extension, application: application, extension_name: BeaconControl::DwellTimeExtension.registered_name)
  end

  let!(:trigger) do
    FactoryGirl.create(:trigger, {
      event_type: 'dwell_time',
      beacons: [beacon],
      application: application,
      dwell_time: Trigger::DWELL_TIME[:default],
      application: application
    })
  end
  let!(:activity) { FactoryGirl.create(:activity, trigger: trigger) }

  before do
    application.create_apns_app_sandbox(
      name: application.name,
      certificate: TEST_CERT
    )
  end

  let(:beacon_event) do
    {
      event_type: 'enter',
      range_id: beacon.id,
      timestamp: 3000
    }
  end

  let(:ep_message) do
    {
      events:      [event],
      application: application,
      user:        user,
      mobile_device: mobile_device,
    }
  end

  describe 'entering into beacon range' do
    let(:event) { beacon_event }

    it 'uses extension custom worker to process event' do
      expect_any_instance_of(BeaconControl::DwellTimeExtension::Worker).to receive(:publish)

      perform_enqueued_jobs do
        EventProcessor.process(ep_message)
      end
    end

    it 'causes push notification schedule' do
      expect {
        perform_enqueued_jobs do
          EventProcessor.process(ep_message)
        end
      }.to change(Rpush::Notification, :count).by(1)
    end
  end
end
