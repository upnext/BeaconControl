###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails_helper'

RSpec.describe BeaconControl::EXTENSIONS, type: :async do
  let(:extensions) {
    BeaconControl.constants.
      select { |c| c =~ /Extension$/ }.
      map { |c| "BeaconControl::#{c}".constantize }
  }

  it { should match_array(extensions) }

  context 'available extension' do
    it 'adds own namespace' do
      described_class.each do |extension|
        expect(Object.const_defined?(extension.to_s)).to eq(true)
      end
    end

    it 'adds own engine' do
      expect(Rails::Engine.subclasses).to include(*described_class.map{|extension| extension::Engine})
    end

    it 'adds own migrations' do
      described_class.each do |extensin|
        migrations = ActiveRecord::Migrator.migrations(
          File.expand_path("../../..", extensin.method(:table_name_prefix).source_location.first)
        ).map &:version

        expect(ActiveRecord::Migrator.get_all_versions).to include(*migrations)
      end
    end

    it 'has own configuration' do
      expect(described_class.map(&:config).map(&:object_id).uniq.count).to eq(described_class.count)
    end
  end

  context 'active extension' do
    let(:application)   { FactoryGirl.create(:application) }
    let(:user)          { FactoryGirl.create(:user) }
    let(:mobile_device) { FactoryGirl.create(:mobile_device, user: user) }
    let(:beacon)        { FactoryGirl.create(:beacon) }

    let(:event) do
      {
        event_type: 'enter',
        range_id: beacon.id,
        timestamp: 3000
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

    it 'plugs itself into event processing flow' do
      described_class.each do |extension|
        FactoryGirl.create(:application_extension, application: application, extension_name: extension.registered_name)
        ExtensionsRegistry.add extension

        expect_any_instance_of(extension::Worker).to receive(:publish) if Object.const_defined?("#{extension}::Worker")
      end

      perform_enqueued_jobs do
        EventProcessor.process(ep_message)
      end
    end
  end
end
