# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "digest"
require "csv"

require_relative "ast_transformer"

module Allure
  class AllureCucumberModel
    extend AstTransformer

    class << self
      # Convert to allure test result
      # @param [Cucumber::Core::Test::Case] test_case
      # @return [TestResult]
      def test_result(test_case)
        TestResult.new(
          name: test_case.name,
          description: description(test_case),
          description_html: description(test_case),
          history_id: Digest::MD5.hexdigest(test_case.inspect),
          full_name: "#{test_case.feature.name}: #{test_case.name}",
          labels: labels(test_case),
          parameters: parameters(test_case) || [],
        )
      end

      # Convert to allure step result
      # @param [Cucumber::Core::Test::Step] test_step
      # @return [StepResult]
      def step_result(test_step)
        StepResult.new(
          name: "#{step(test_step).keyword}#{test_step.text}",
          attachments: [multiline_arg_attachment(test_step)].compact,
        )
      end

      # Convert to allure step result
      # @param [Cucumber::Core::Test::Step] test_step
      # @return [StepResult]
      def fixture_result(test_step)
        location = test_step.location.to_s.split("/").last
        FixtureResult.new(name: location)
      end

      # Convert result to status detail
      # @param [Cucumber::Core::Test::Result] result
      # @return [StatusDetails]
      def status_details(result)
        StatusDetails.new(**{ flaky: result.flaky? }.merge(failure_details(result)))
      end

      private

      # Get thread specific lifecycle
      # @return [Allure::AllureLifecycle]
      def lifecycle
        Allure.lifecycle
      end

      def labels(test_case)
        feature_labels = %w[feature package suite].map { |name| Label.new(name, test_case.feature.name) }
        scenario_labels = %w[story testClass].map { |name| Label.new(name, test_case.name) }
        tag_labels = test_case.tags.map { |tag| Label.new("tag", tag.name.delete_prefix("@")) }

        feature_labels + scenario_labels + tag_labels
      end

      def parameters(test_case)
        example_row(test_case)&.values&.map { |value| Parameter.new("argument", value) }
      end

      def description(test_case)
        scenario = scenario(test_case)
        scenario.description.empty? ? "Location - #{scenario.file_colon_line}" : scenario.description
      end

      def failure_details(result)
        return { message: result.exception.message, trace: result.exception.backtrace.join("\n") } if result.failed?
        return { message: result.message, trace: result.backtrace.join("\n") } if result.undefined?

        {}
      end

      def multiline_arg_attachment(test_step)
        arg = multiline_arg(test_step)
        return unless arg

        arg.data_table? ? data_table_attachment(arg) : docstring_attachment(arg)
      end

      def data_table_attachment(multiline_arg)
        attachment = lifecycle.prepare_attachment("data-table", ContentType::CSV)
        csv = multiline_arg.raw.each_with_object([]) { |row, arr| arr.push(row.to_csv) }.join("")
        lifecycle.write_attachment(csv, attachment)
        attachment
      end

      def docstring_attachment(multiline_arg)
        attachment = lifecycle.prepare_attachment("docstring", ContentType::TXT)
        lifecycle.write_attachment(multiline_arg.content, attachment)
        attachment
      end
    end
  end
end
