module AllureCucumber
  module DSL

    def attach_file(title, file)
      @tracker = AllureCucumber::FeatureTracker.tracker
      AllureRubyAdaptorApi::Builder.add_attachment(@tracker.feature_name, @tracker.scenario_name, :step => @tracker.step_name, :file => file, :title => title)
    end

  end
end
