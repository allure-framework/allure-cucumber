require "allure-cucumber/version"
require 'allure-cucumber/dsl'
require 'allure-cucumber/builder'
require 'allure-cucumber/formatter'

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
    end
  end
  
end
