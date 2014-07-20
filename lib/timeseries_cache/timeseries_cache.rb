require 'active_support/time'
require_relative './lib/base'
require_relative './lib/day'
require_relative './lib/week'
require_relative './lib/month'
require_relative './lib/quarter'
require_relative './lib/year'

module TimeseriesCache
  class MissingValue < StandardError ; end
  class MissingOption < StandardError ; end
end
