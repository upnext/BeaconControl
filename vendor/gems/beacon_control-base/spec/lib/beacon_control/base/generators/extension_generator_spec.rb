###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'spec_helper'

describe BeaconControl::Base::ExtensionGenerator, type: :generator do

  let(:gem_path) { 'vendor/gems/beacon_control-test_extension' }
  let(:gem_files) { [
    'beacon_control-test_extension.gemspec',
    'lib/beacon_control/test_extension.rb',
    'lib/beacon_control/test_extension/engine.rb',
    'config/routes.rb',
    'config/locales/test_extension.yml',
    'config/initializers/test_extension.rb'
  ] }
  let(:assets_files) { [
    'app/assets/javascripts/test_extension.js',
    'app/assets/stylesheets/test_extension.css'
  ] }

  it 'should run all tasks in the generator' do
    gen = generator %w(test)
    gen.should_receive :create_gem_structure
    gen.should_receive :copy_module_file
    gen.should_receive :copy_engine_file
    capture(:stdout) { gen.invoke_all }
  end

  it 'generates extension gem base structure' do
    expect(file(gem_path)).not_to exist
    run_generator %w(test)
    expect(file(gem_path)).to exist

    (gem_files + assets_files).each do |file_path|
      expect(file("#{gem_path}/#{file_path}")).to exist
    end
  end

  it 'creates proper extension modules and classes names' do
    run_generator %w(test)

    expect(file("#{gem_path}/lib/beacon_control/test_extension.rb")).to contain(/module BeaconControl.*module TestExtension/m)
    expect(file("#{gem_path}/lib/beacon_control/test_extension/engine.rb")).to contain(/module BeaconControl.*module TestExtension.*class Engine < Rails::Engine/m)
    expect(file("#{gem_path}/config/routes.rb")).to contain("BeaconControl::TestExtension::Engine.routes.draw")
    expect(file("#{gem_path}/config/locales/test_extension.yml")).to contain(/en:.*test_extension:.*sidebar_links:/m)
    expect(file("#{gem_path}/config/initializers/test_extension.rb")).to contain("BeaconControl::TestExtension.configure do |config|")
  end

  it 'skips assets files generation if needed' do
    run_generator %w(test --skip-assets)

    assets_files.each do |file_path|
      expect(file("#{gem_path}/#{file_path}")).not_to exist
    end
  end
end
