module AllureCucumber
  module DSL

    def attach_file(title, file)
      @tracker = AllureCucumber::FeatureTracker.tracker
      if @tracker.scenario_name
        AllureRubyAdaptorApi::Builder.add_attachment(@tracker.feature_name, @tracker.scenario_name, :step => @tracker.step_name, :file => file, :title => title)
      else
        # TODO: This is possible for background steps.  
        puts "Cannot attach #{title} to step #{@tracker.step_name} as scenario name is undefined"
      end
    end

  end
end
