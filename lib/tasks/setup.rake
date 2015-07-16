###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require "string"

namespace :setup do
  desc "Run all setup tasks"
  task :all do
    Rake::Task["setup:config"].invoke
    Rake::Task["setup:bundle"].invoke
    Rake::Task["setup:requires"].invoke
    Rake::Task["setup:verify"].invoke
    Rake::Task["setup:database"].invoke
    Rake::Task["setup:initial"].invoke
    puts "All done!".green

    Rake::Task["setup:run"].invoke
  end

  desc "Setup database.yml, config.yml & sidekiq.yml config files"
  task :config do
    Rails::Generators.invoke("beacon_control:setup")
  end

  desc "run bundler"
  task :bundle do
    puts "\n== Installing dependencies =="

    # Run bundler
    system "gem install bundler --conservative"
    system "bundle check || bundle install"
  end

  desc "Check required binaries"
  task :requires do
    puts "\n== Binaries check =="

    # Check other binaries versions
    if File.exist?("config/requires.yml")
      YAML.load_file("config/requires.yml").each do |key, req|

        if key == "database"
          req = req[Rails.application.config.database_configuration[Rails.env]["adapter"]]
        end

        begin
          req_version = `#{req['command']}`.match(/#{req['matcher']}/).captures.first
          req_ok = Gem::Version.new(req_version) >= Gem::Version.new(req['minimum'])

          puts "#{req['name']} version: #{req_version}".send(req_ok ? :green : :red)
          unless req_ok
            puts "  #{req['name']} #{req_version} is too old and >= #{req['suggested']} is advised"
            puts "  Visit #{req['install']} for instructions"
          end
        rescue Errno::ENOENT
          puts "#{req['name']} not found in the system".red
          puts "  Visit #{req['install']} for instructions"
          abort
        end
      end
    end
  end

  desc "Verify connection settings"
  task :verify do
    puts "\n== Verify connection settings =="

    # Test database connection
    begin
      config = Rails.application.config.database_configuration[Rails.env]
      case config["adapter"]
      when "mysql2"
        config.merge!({database: "mysql"})
      when "postgresql"
        config.merge!({database: "postgres"})
      end
      ActiveRecord::Base.establish_connection(config).connection.disconnect!
      puts "#{config['adapter'].humanize} [OK]".green
    rescue Mysql2::Error => e
      puts "#{config['adapter'].humanize} [#{e}]".red
      abort
    end

    # Test Redis connection
    begin
      Redis.new({url: AppConfig.redis_url}).ping
      puts "Redis [OK]".green
    rescue SocketError => e
      puts "Redis [#{e}]".red
      abort
    end
  end

  desc "Create database"
  task :database => :environment do
    puts "\n== Create database =="

    begin
      oldstdout = $stdout
      $stdout = StringIO.new
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      $stdout = oldstdout
      puts "OK".green
    rescue => e
      $stdout = oldstdout
      puts e.message.red
      abort
    end
  end

  desc "Initial setup"
  task :initial => :environment do
    puts "\n== Create admin account =="

    # Get new admin *valid* credentials
    ActiveRecord::Base.descendants.each{ |c| c.reset_column_information }
    %w(brand account admin).each do |model|
      require_dependency Rails.root.join("app/models", "#{model}.rb")
    end
    thor = Thor::Shell::Basic.new
    begin
      ENV["SEED_ADMIN_EMAIL"]    = thor.ask("Admin email:")
      ENV["SEED_ADMIN_PASSWORD"] = thor.ask("Admin password:", echo: false)
      admin = Admin.new(
        email:                 ENV["SEED_ADMIN_EMAIL"],
        password:              ENV["SEED_ADMIN_PASSWORD"],
        password_confirmation: ENV["SEED_ADMIN_PASSWORD"]
      )
      puts "\n#{admin.errors.full_messages.join(', ')}".red unless admin.valid?
    end while not admin.valid?
    puts

    Rake::Task["db:seed"].invoke
    Admin.last.try :send_confirmation_instructions
  end

  desc "Run application"
  task :run do
    puts "\n== Run application =="

    system "foreman start"
  end
end
