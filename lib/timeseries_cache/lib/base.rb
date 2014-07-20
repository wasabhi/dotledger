module TimeseriesCache
  class Base
    attr_reader :key, :redis, :timestep, :ttl, :normalize_datetime

    def initialize(options, &block)
      @key = options.fetch(:key) { raise MissingOption.new("missing option :key") }
      @redis = options.fetch(:redis, $redis)
      @timestep = options.fetch(:timestep, method(:default_timestep))
      @normalize_datetime = options.fetch(:normalize_datetime, method(:default_normalize_datetime))
      @ttl = options.fetch(:ttl, false)
    end

    def get(datetime)
      if set?(datetime)
        load_value(redis.get(prefixed_key(datetime)))
      else
        raise MissingValue.new("missing #{key} at #{datetime.inspect}")
      end
    end

    def fetch(datetime, &block)
      begin
        get(datetime)
      rescue MissingValue
        set(datetime, &block)
      end
    end

    def fetch_range(datetime_from, datetime_to, &block)
      [].tap do |output|
        datetime = datetime_from
        # Add an additional timestep to make the range inclusive
        while datetime < (datetime_to + timestep.call(datetime_to))
          output << fetch(datetime, &block)
          datetime = datetime + timestep.call(datetime)
        end
      end
    end

    def set(datetime, value = nil)
      val = block_given? ? yield(datetime, timestep.call(datetime)) : value
      redis.set(prefixed_key(datetime), dump_value(val))
      set_ttl(datetime)
      val
    end

    def set?(datetime)
      redis.exists(prefixed_key(datetime))
    end

    def dump_value(value)
      Marshal.dump(value)
    end

    def load_value(value)
      Marshal.load(value)
    end

    private
    def set_ttl(datetime)
      redis.expire(prefixed_key(datetime), ttl) if ttl
    end

    def prefixed_key(datetime)
      [key, normalize_datetime.call(datetime)].join(':')
    end

    def default_timestep(datetime)
      raise NotImplementedError.new("default_timestep")
    end

    def default_normalize_datetime(datetime)
      raise NotImplementedError.new("default_normalize_datetime")
    end
  end
end
