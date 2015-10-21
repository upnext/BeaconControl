module Mailchimp
  extend ::ActiveSupport::Autoload

  class << self
    def client
      client = Gibbon::Request.new(api_key: AppConfig.mailchimp_key)
      client.timeout = 10
      client
    end
  end
end