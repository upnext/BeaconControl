###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe EventProcessor::Message do
  let(:params) do
    {
      events: events,
      user: user,
      application: application,
      mobile_device: mobile_device
    }
  end

  let(:events)        { [{}] }
  let(:user)          { double }
  let(:mobile_device) { double }
  let(:application)   { double}

  describe 'valid?' do
    context 'when all required parameters are provided' do
      it 'returns true' do
        expect(described_class.new(params).valid?).to eq(true)
      end
    end

    context 'when events are not present' do
      let(:events) { nil }

      it 'returns false' do
        expect(described_class.new(params).valid?).to eq(false)
      end
    end

    context 'when events are empty array' do
      let(:events) { [] }

      it 'returns false' do
        expect(described_class.new(params).valid?).to eq(false)
      end
    end

    context 'when user is not present' do
      let(:user) { nil }

      it 'returns false' do
        expect(described_class.new(params).valid?).to eq(false)
      end
    end

    context 'when mobile device is not present' do
      let(:mobile_device) { nil }

      it 'returns false' do
        expect(described_class.new(params).valid?).to eq(false)
      end
    end

    context 'when application is not present' do
      let(:application) { nil }

      it 'returns false' do
        expect(described_class.new(params).valid?).to eq(false)
      end
    end
  end
end
