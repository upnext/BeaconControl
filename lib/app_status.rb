###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'active_record'

class AppStatus
  def self.logger
    @logger ||= Rails.logger
  end

  class Rack
    def initialize
      @store = []
      yield self
    end

    def add_class(klazz, name:)
      @store << OpenStruct.new(check_class: klazz, name: name)
    end

    def call(env)
      output = @store.reduce({}) do |memo, data|
        memo[data.name] = data.check_class.new.ok?
        memo
      end

      output[:overall_ok?] = output.values.all?

      [200, headers, [format_response(output)]]
    end

    private

    def headers
      {'Content-Type' => 'application/json'}
    end

    def format_response(output)
      JSON.dump(output)
    end
  end

  class CheckRequest
    def log_error(e)
      AppStatus.logger.error("[AppStatus] Database connection check yielded error (#{e.message})")
      AppStatus.logger.debug("[AppStatus] Backtrace: \n #{e.backtrace.join("\n")}")
    end

    def log_status(status)
      AppStatus.logger.debug("[AppStatus] Database connection status is #{status}")
      status
    end

    def ok?
      check!
      log_status(true)
    rescue StandardError => error
      log_error(error)
      log_status(false)
    end
  end

  class DatabaseCheckRequest < CheckRequest
    def check!
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        data = connection.execute("SELECT VERSION() AS version").first
        version = data.is_a?(Hash) ? data["version"] : data.first
        version.to_s.start_with? '5'
      end
    end
  end

  class MigrationsCheckRequest < CheckRequest
    def check!
      !ActiveRecord::Migrator.needs_migration?
    end
  end
end