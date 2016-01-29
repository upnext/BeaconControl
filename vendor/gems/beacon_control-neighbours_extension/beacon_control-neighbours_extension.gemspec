# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beacon_control/neighbours_extension/version'

Gem::Specification.new do |spec|
  spec.name          = "beacon_control-neighbours_extension"
  spec.version       = BeaconControl::NeighboursExtension::VERSION
  spec.authors       = ["Adrian Wozniak"]
  spec.email         = ["adrian.wozniak@ita-prog.pl"]

  spec.summary       = %q{Awesome zone neighbours builder}
  spec.description   = %q{Full featured, awesome zone neighbours builder}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "BSD"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'sprockets', '>= 3.0.0'
  spec.add_dependency 'sprockets-es6', '0.7.0'
end
