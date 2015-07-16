###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe KontaktIo::Resource::Manager do
  let(:attributes) {
    {
      ID:          1,
      FirstName:   "John",
      last_name:   "Doe",
      devicesCount: 50
    }
  }

  let(:subject) { described_class.new(attributes) }

  describe '#initalize' do
    it { should respond_to(:id) }
    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:devices_count) }

    it { should_not respond_to(:ID) }
    it { should_not respond_to(:FirstName) }
    it { should_not respond_to(:devicesCount) }

    it 'assigns attributes' do
      expect(subject.id).to eq("1")
      expect(subject.first_name).to eq("John")
      expect(subject.last_name).to eq("Doe")
      expect(subject.devices_count).to eq(50)
    end
  end
end
