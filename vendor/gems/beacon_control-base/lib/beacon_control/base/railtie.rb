###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module Base
    class Railtie < Rails::Railtie
      BeaconControl::Base.register_extension(
        'beacon_control-base',
        BeaconControl::Base
      )

      config.before_configuration do |app|
        append_autoload_dir(File.expand_path('../../../..', __FILE__).to_s)
        append_autoload_dir(app.root)
        exec_autoload_dirs
        app.paths.values
      end

      def self.append_autoload_dir(dir)
        @after_here_exec ||= []
        @after_here_exec.prepend dir
      end

      def self.exec_autoload_dirs
        (@after_here_exec || []).each do |dir|
          load_for_dir(dir)
        end
      end

      def self.load_for_dir(dir)
        config.before_configuration do |app|
          Dir["#{dir}/app/*"].each do |path|
            /(?<p>app\/\w+)$/ =~ path.to_s
            next unless defined?(p) and p.present?
            next if /(views|assets)$/ =~ p
            if app.paths[p].blank?
              app.paths.add p, eager_load: true, load_path: true
            end
            app.paths[p] << path
          end
        end
      end

      config.after_initialize { BeaconControl::Base.exec_load }

      config.before_eager_load { BeaconControl::Base.exec_load }

      config.to_prepare { BeaconControl::Base.exec_load }
    end
  end
end
