module TimeseriesCache
  class Week < Base
    def default_timestep(datetime)
      1.week
    end

    def default_normalize_datetime(datetime)
      datetime.beginning_of_week
    end
  end
end
