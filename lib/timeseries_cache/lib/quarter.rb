module TimeseriesCache
  class Quarter < Base
    def default_timestep(datetime)
      3.months
    end

    def default_normalize_datetime(datetime)
      datetime.beginning_of_quarter
    end
  end
end
