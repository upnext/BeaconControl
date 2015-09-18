class BaseFormatter < ::Logger::Formatter
  private

  def msg2str(msg)
    case msg
    when ::String
      msg.squish
    when ::Exception
      "#{ msg.message } (#{ msg.class })\n #{(msg.backtrace || []).join("\n")}"
    else
      msg.inspect
    end
  end

  def request_env
    Thread.current[:request_env] || {}
  end

  def correlation_id
    Thread.current[:request_correlation_id]
  end

  def entry_point_msg
    if Thread.current[:entry_point].present?
      [Thread.current[:entry_point]]
    else
      []
    end
  end

  def correlation_id_msg
    "[#{correlation_id}]"
  end

  def query_string
    request_env["QUERY_STRING"].present? ? "?"+ URI.unescape(request_env["QUERY_STRING"]) : ""
  end
end

class FileLogFormatter < BaseFormatter
  FORMAT = %{%s %s %s %s%s %s %s %s [%s] %s\n}

  def call(severity, time, progname, msg)
    return if msg2str(msg).blank?

    FORMAT % [
      time.strftime("%d/%b/%Y %H:%M:%S %z"),
      request_env['HTTP_X_FORWARDED_FOR'] || request_env["REMOTE_ADDR"] || "-",
      request_env["REQUEST_METHOD"] || "-",
      request_env["PATH_INFO"] || "-",
      query_string,
      request_env["HTTP_VERSION"] || "-",
      correlation_id_msg,
      entry_point_msg,
      severity,
      msg2str(msg)
    ]
  end
end

log_path = Rails.root.join(AppConfig.log_path.presence || "log/#{Rails.env}.log")

logger = ::Logger.new(log_path)
logger.formatter = FileLogFormatter.new
logger.level = ::Logger.const_get(AppConfig.log_level.upcase)

Rails.logger = logger
ActionController::Base.logger = logger
ActiveRecord::Base.logger = logger
