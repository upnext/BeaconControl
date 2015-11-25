require 'sprockets'
require 'sprockets/es6'

module BeaconControl
  module NeighboursExtension
    class Engine < Rails::Engine
      isolate_namespace BeaconControl::NeighboursExtension

      initializer 'neighbours_extension', before: :load_config_initializers do |app|
        config.paths['db/migrate'].expanded.each do |expanded_path|
          app.config.paths['db/migrate'] << expanded_path
        end
      end

      initializer 'neighbours.assets.precompile', after: :load_config_initializers do |app|
        app.config.assets.precompile += %w(
            neighbours_extension.js
            neighbours_extension.css
          )
      end
    end
  end
end