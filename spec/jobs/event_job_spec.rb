###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe EventJob do
  let(:job) { described_class.new }

  let(:events) { [] }

  let(:message) do
    {
      events:        events,
      user:          double(present?: true),
      mobile_device: double(present?: true),
      application:   double(present?: true),
    }
  end

  after do
    job.perform(message)
  end

  describe 'when message is valid' do
    let(:events) do
      [{}]
    end

    it 'is passed to MessageDispatcher' do
      expect(EventProcessor::MessageDispatcher).to receive(:new) { double(dispatch: true) }
    end
  end

  describe 'when message is invalid' do
    it 'is not passed to MessageDispatcher' do
      expect(EventProcessor::MessageDispatcher).to_not receive(:new)
    end
  end
end
