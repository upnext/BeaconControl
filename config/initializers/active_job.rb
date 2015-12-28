Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  config.redis = { url: AppConfig.redis_url, namespace: 'beacon-control' }
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
  config.redis = { url: AppConfig.redis_url, namespace: 'beacon-control' }
end

ActiveJob::Base.queue_adapter = :sidekiq

Sidekiq::Logging.logger.level = Rails.logger.level
