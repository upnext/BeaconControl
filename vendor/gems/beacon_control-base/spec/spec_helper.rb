###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

ENV["RAILS_ENV"] = "test"

require 'rspec/expectations'
require 'ammeter/init'
require 'beacon_control/base'
require 'helpers/test_extension'

RSpec.configure do |config|
  config.include RSpec::Matchers

  config.order = "random"
  config.mock_with :rspec
end
