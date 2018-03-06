module AllureCucumber
  
  class FeatureTracker

    attr_accessor :feature_name, :scenario_name, :step_name, :step_line
    @@tracker = nil

    def self.create
      @@tracker = FeatureTracker.new unless @@tracker
      private_class_method :new
      @@tracker
    end

    def self.tracker
      @@tracker
    end
    
  end
end
