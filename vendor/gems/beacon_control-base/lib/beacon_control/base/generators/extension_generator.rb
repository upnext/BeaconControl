###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module Base
    require 'rails/generators'

    #
    # Rails generator for extension gem structure.
    #
    class ExtensionGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      class_option :skip_assets,
                   type: 'boolean',
                   desc: 'Skips generating .js and .css assets files'

      class_option :root_dir,
                   type: 'string',
                   default: 'vendor/gems',
                   aliases: '-r',
                   desc: 'Indicates where to generate gem structure'

      #
      # Redefines banner(first line) text for generator usage output. Displayed when
      # generator ran incorrectly, or with -h parameter.
      #
      def self.banner
        command = $0 =~ /beacon-os$/ ? "beacon-os generate-extension" : "rails generate #{namespace.sub(/^rails:/,'')}"
        "#{command} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]".gsub(/\s+/, ' ')
      end

      def initialize_variables
        @gem_name = "beacon_control-#{file_name}_extension"
        @root_dir = options[:root_dir]
        @gem_dir = File.join(@root_dir, @gem_name)
        @lib_dir = File.join(@gem_dir, "lib", "beacon_control", "#{file_name}_extension")
      end

      #
      # Runs bundler command in shell to create new gem.
      #
      def create_gem_structure
        empty_directory @root_dir
        inside @root_dir do
          run "bundle gem #{@gem_name}"
          remove_file "#{@gem_name}/Gemfile"
        end
      end

      def copy_module_file
        template "module.rb.erb", "#{@lib_dir}.rb", force: true
      end

      def copy_engine_file
        template "engine.rb.erb", "#{@lib_dir}/engine.rb"
      end

      def copy_routes_file
        template "routes.rb.erb", "#{@gem_dir}/config/routes.rb"
      end

      def copy_locales_file
        template "locales.yml.erb", "#{@gem_dir}/config/locales/#{file_name}_extension.yml"
      end

      def copy_initializer_file
        template "initializer.rb.erb", "#{@gem_dir}/config/initializers/#{file_name}_extension.rb"
      end

      def copy_assets_files
        unless options[:skip_assets]
          template "javascripts.js.erb", "#{@gem_dir}/app/assets/javascripts/#{file_name}_extension.js"
          template "stylesheets.css.erb", "#{@gem_dir}/app/assets/stylesheets/#{file_name}_extension.css"
        end
      end
    end
  end
end
