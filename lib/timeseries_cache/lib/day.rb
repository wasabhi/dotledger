module TimeseriesCache
  class Day < Base
    def default_timestep(datetime)
      1.day
    end

    def default_normalize_datetime(datetime)
      timestamp = datetime.to_datetime.to_i
      timestamp - (timestamp % timestep.call(datetime))
    end
  end
end
