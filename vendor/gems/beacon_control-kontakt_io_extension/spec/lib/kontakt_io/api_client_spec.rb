###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

RSpec.describe KontaktIo::ApiClient do
  let(:api_client) { described_class.new('api_key') }

  before do
    allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(response)
  end

  describe '#managers' do
    context 'on success' do
      let(:response) { OpenStruct.new({'success?' => true, 'body' => fixture_content('responses/managers.json')}) }

      it 'fetches managers' do
        expect {
          managers = api_client.managers

          expect(managers.class).to be(Array)
          expect(managers.size).to eq(3)
          expect(managers.first.class).to be(KontaktIo::Resource::Manager)
          expect(managers.first.id).to eq("65a0c6d5-5edc-877f-a4de-81308ea7d876")
        }.not_to raise_error
      end
    end

    context 'on error' do
      let(:response) { OpenStruct.new({'success?' => false, 'status' => 400, 'body' => nil}) }

      it 'raises error' do
        expect{
          managers = api_client.managers
        }.to raise_error(KontaktIo::Error)
      end
    end
  end

  describe "#beacons" do
    let(:response) { OpenStruct.new({'success?' => true, 'body' => fixture_content('responses/beacons.json')}) }

    it 'fetches beacons' do
      expect {
        beacons = api_client.beacons

        expect(beacons.class).to be(Array)
        expect(beacons.size).to eq(3)
        expect(beacons.first.class).to be(KontaktIo::Resource::Beacon)
        expect(beacons.first.unique_id).to eq("0YA4")
      }.not_to raise_error
    end
  end
end
