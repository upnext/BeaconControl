###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beacon_control/backend_request_extension/version'

Gem::Specification.new do |spec|
  spec.name          = "beacon_control-backend_request_extension"
  spec.version       = BeaconControl::BackendRequestExtension::VERSION
  spec.authors       = ["Upnext Ltd."]
  spec.email         = ["backend-dev@up-next.com"]
  spec.summary       = %q{BeaconControl::BackendRequestExtension}
  spec.description   = %q{BeaconControl::BackendRequestExtension}
  spec.homepage      = ""
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "database_cleaner"
end
