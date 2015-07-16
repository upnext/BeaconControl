###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe BeaconControl::DwellTimeExtension::WorkerJob, type: :async do
  describe '#perform' do
    let(:event_type) { 'foo' }

    let(:message) do
      {
        event_type: event_type
      }
    end

    after do
      perform_enqueued_jobs do
        described_class.perform_later(message)
      end
    end

    context 'when event_type == enter' do
      let(:event_type) { 'enter' }

      it 'dispatches event to EnterEvent' do
        expect(BeaconControl::DwellTimeExtension::EnterEvent).to receive(:new).and_return(double(call: true))
      end
    end

    context 'when event_type == leave' do
      let(:event_type) { 'leave' }

      it 'dispatches event to EnterEvent' do
        expect(BeaconControl::DwellTimeExtension::LeaveEvent).to receive(:new).and_return(double(call: true))
      end
    end


    context 'when event_type is undefined' do
      it 'ignores event' do
        expect(BeaconControl::DwellTimeExtension::EnterEvent).to_not receive(:new)
        expect(BeaconControl::DwellTimeExtension::LeaveEvent).to_not receive(:new)
      end
    end
  end
end
