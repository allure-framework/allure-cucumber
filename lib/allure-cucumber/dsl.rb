module AllureCucumber
  module DSL

    def attach_file(title, file, attach_to_step=true)
      @tracker = AllureCucumber::FeatureTracker.tracker
      options = {:file => file, :title => title}
      options.merge!(:step => @tracker.step_name) if attach_to_step
      AllureRubyAdaptorApi::Builder.add_attachment(@tracker.feature_name, @tracker.scenario_name, options)
    end

  end
end
