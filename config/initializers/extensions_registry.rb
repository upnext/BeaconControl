ExtensionsRegistry = Extensions::Registry.new do |registry|
  BeaconControl::EXTENSIONS.map do |ext|
    registry.add ext
  end
end
