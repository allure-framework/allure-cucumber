# frozen_string_literal: true

module Allure
  class CucumberConfig
    class << self
      DEFAULT_TMS_PREFIX = "@TMS:"
      DEFAULT_ISSUE_PREFIX = "@ISSUE:"
      DEFAULT_SEVERITY_PREFIX = "@SEVERITY:"

      attr_writer :output_dir, :tms_prefix, :issue_prefix, :severity_prefix

      def output_dir
        Allure::Config.output_dir
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
end
