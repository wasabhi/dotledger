module TimeseriesCache
  class Year < Base
    def default_timestep(datetime)
      1.year
    end

    def default_normalize_datetime(datetime)
      datetime.beginning_of_year
    end
  end
end
