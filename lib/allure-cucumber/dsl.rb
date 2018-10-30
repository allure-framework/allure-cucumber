module AllureCucumber
  module DSL

    def attach_file(title, file, attach_to_step=true, mime_type=nil)
      @tracker = AllureCucumber::FeatureTracker.tracker
      options = {:file => file, :title => title, :mime_type => mime_type}
      options.merge!(:step_id => @tracker.step_id) if attach_to_step
      if @tracker.scenario_name
        AllureRubyAdaptorApi::Builder.add_attachment(@tracker.feature_name, @tracker.scenario_name, options)
      else
        # TODO: This is possible for background steps.  
        puts "Cannot attach #{title} to step #{@tracker.step_name} as scenario name is undefined"
      end
    end

  end
end
