Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDISCLOUD_URL'], ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
end