require 'allure-ruby-api'
require 'allure-cucumber/version'
require 'allure-cucumber/formatter'
require 'allure-cucumber/feature_tracker'
require 'allure-cucumber/dsl'

module AllureCucumber
  
  module Config
    class << self
      attr_accessor :output_dir
      
      DEFAULT_OUTPUT_DIR = 'allure/data'
      
      def output_dir
        @output_dir || DEFAULT_OUTPUT_DIR
      end
      
    end 
  end

  class << self
    def configure(&block)
      yield Config
      AllureRubyApi.configure do |c|
        c.output_dir = Config.output_dir
      end
    end
  end
  
end
