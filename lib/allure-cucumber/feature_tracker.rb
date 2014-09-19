module AllureCucumber

  class FeatureTracker
    include Singleton
    attr_accessor :feature_name, :scenario_name, :step_name

    def [](feature_name)
      @feature_meta ||= {}
      @feature_meta[feature_name]
    end

    def []=(feature_name, value)
      @feature_meta ||= {}
      @feature_meta[feature_name] = value
    end
  end
end
