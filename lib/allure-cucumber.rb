require "allure-ruby-adaptor-api"
require "allure-cucumber/version"
require "allure-cucumber/feature_tracker"
require "allure-cucumber/dsl"
require "allure-cucumber/formatter"

module AllureCucumber

  module Config
    class << self

      attr_accessor :output_dir, :clean_dir, :tms_prefix, :issue_prefix, :severity_prefix

      DEFAULT_OUTPUT_DIR      = "gen/allure-results"
      DEFAULT_TMS_PREFIX      = "@TMS:"
      DEFAULT_ISSUE_PREFIX    = "@ISSUE:"
      DEFAULT_SEVERITY_PREFIX = "@SEVERITY:"

      def output_dir
        @output_dir || DEFAULT_OUTPUT_DIR
      end

      def output_dir=(output_dir)
        AllureRubyAdaptorApi::Config.output_dir = output_dir
        @output_dir = output_dir
      end

      def tms_prefix
        @tms_prefix || DEFAULT_TMS_PREFIX
      end

      def issue_prefix
        @issue_prefix || DEFAULT_ISSUE_PREFIX
      end

      def severity_prefix
        @severity_prefix || DEFAULT_SEVERITY_PREFIX
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
