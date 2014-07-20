module TimeseriesCache
  class Month < Base
    def default_timestep(datetime)
      1.month
    end

    def default_normalize_datetime(datetime)
      datetime.beginning_of_month
    end
  end
end
