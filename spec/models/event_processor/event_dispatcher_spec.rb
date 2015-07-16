###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe EventProcessor::EventDispatcher do
  let(:event)      { double(event_type: event_type, with_action?: false, attributes: double) }

  let(:extensions) { [double(name: 'One'), double(name: 'Two')] }

  subject { described_class.new(event: event, extensions: extensions) }

  after do
    subject.dispatch
  end

  context 'when event type is present' do
    let(:event_type) { double(present?: true) }

    it 'dispatches event to given extensions' do
      extensions.each {|ext| expect(ext).to receive(:publish).with(event) }
    end
  end

  context 'when event type is not present' do
    let(:event_type) { double(present?: false) }

    it 'does not dispatch event to given extensions' do
      extensions.each {|ext| expect(ext).to_not receive(:publish) }
    end
  end
end
