require 'redis'
require 'redis-namespace'

$redis = Redis::Namespace.new(
  Rails.application.secrets.redis_namespace,
  redis: Redis.new(url: Rails.application.secrets.redis_url)
)
