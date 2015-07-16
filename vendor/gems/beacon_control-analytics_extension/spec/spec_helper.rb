###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../../../../config/environment", __FILE__)
require "rspec/rails"
require "beacon_control/base/spec_helper"

FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]
FactoryGirl.find_definitions

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include RSpec::Matchers

  config.infer_spec_type_from_file_location!

  config.order = "random"

  config.mock_with :rspec

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    ExtensionsRegistry.clear
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    ExtensionsRegistry.clear
  end
end
