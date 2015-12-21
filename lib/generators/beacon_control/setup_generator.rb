###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'rails/generators'

module BeaconControl
  class SetupGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def setup_database_config_file
      say "\n== Setup database connection =="

      @adapter =  ask "Database adapter:",  default: "mysql2", limited_to: ["mysql2", "postgresql"]
      @host =     ask "Database host:",     default: "localhost"
      @username = ask "Database username:", default: `whoami`.strip
      @password = ask "Database password:", echo: false
      say ""

      case @adapter
      when "mysql2"
        gem "mysql2"
      when "postgresql"
        gem "pg"
      end

      template "database.yml.erb", "config/database.yml", force: true
    end

    def setup_config_file
      say "\n== Setup application config =="

      @secret_key_base                = SecureRandom.hex(64)
      @registerable                   = yes? "Allow external user registration? (y)es/(n)o"
      @confirmable                    = yes? "Require admin users email confirmation? (y)es/(n)o"
      @create_test_app_on_new_account = yes? "Create test application on new account? (y)es/(n)o"

      say "\nAutoloading extensions"
      @autoload_extensions = {
        analytics:  yes?("Analytics? (y)es/(n)o"),
        dwell_time: yes?("DwellTime? (y)es/(n)o"),
        kontakt_io: yes?("Kontakt.io? (y)es/(n)o"),
        presence:   yes?("Presence? (y)es/(n)o"),
      }
      say ""

      @redis_url       = ask "Redis URL:", default: "localhost:6379"

      say "\nSMTP settings"
      @smtp_settings = {
        address:              ask("Address:",        default: "smtp.gmail.com"),
        port:                 ask("Port:",           default: 587),
        domain:               ask("Domain:",         default: "beacon-os.com"),
        authentication:       ask("Authentication:", default: "plain"),
        enable_starttls_auto: yes?("Enable starttls auto? (y)es/(n)o"),
        user_name:            ask("Username:",       default: "noreply@beacon-os.com"),
        password:             ask("Password:",       echo: false)
      }
      say ""
      @mailer_sender          = ask "Mailer sender:",          default: "noreply@beacon-os.com"
      @system_mailer_receiver = ask "System emails receiver:", default: "noreply@beacon-os.com"
      @mailer_url_options = {
        host: ask("Mailer URLs host:", default: "localhost"),
        port: ask("Mailer URLs port:", default: 3000)
      }

      template "config.yml.erb", "config/config.yml", force: true
    end

    def setup_sidekiq_config_file
      say "\n== Setup Sidekiq config =="

      @pidfile = ask "PID file:", default: "./tmp/pids/sidekiq.pid"
      @logfile = ask "Log file:", default: "./log/sidekiq.log"

      template "sidekiq.yml.erb", "config/sidekiq.yml", force: true
    end
  end
end
