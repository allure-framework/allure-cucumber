require 'allure-ruby-adaptor-api'
require 'allure-cucumber/version'
require 'allure-cucumber/feature_tracker'
require 'allure-cucumber/dsl'
require 'allure-cucumber/formatter'

module AllureCucumber
  
  module Config
    class << self
      attr_accessor :output_dir, :clean_dir
      
      DEFAULT_OUTPUT_DIR = 'gen/allure-results'
      
      def output_dir
        @output_dir || DEFAULT_OUTPUT_DIR
      end
      
    end 
  end

  class << self
    def configure(&block)
      yield Config
      AllureRubyAdaptorApi.configure do |c|
        c.output_dir = Config.output_dir
      end
    end
  end
  
end
