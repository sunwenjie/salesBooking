server = Settings.redis.server
port = Settings.redis.port
db_num = Settings.redis.db_num
password = Settings.redis.password

Sidekiq.default_worker_options = {:retry => 0}

Sidekiq.configure_server do |config|  

  redis_config = { url: "redis://#{server}:#{port}/#{db_num}"}

  redis_config.merge!({password: password}) if password!=''

  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  redis_config = { url: "redis://#{server}:#{port}/#{db_num}"}

  redis_config.merge!({password: password}) if password!=''

  config.redis = redis_config
end