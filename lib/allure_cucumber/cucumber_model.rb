# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "digest"

module Allure
  class AllureCucumberModel
    class << self
      # Convert to allure test result
      # @param [Cucumber::Core::Test::Case] test_case
      # @return [TestResult]
      def test_result(test_case)
        TestResult.new(
          name: test_case.name,
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
        StepResult.new(name: "#{keyword(test_step)}#{test_step.text}")
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
        options = { flaky: result.flaky? }
        if result.failed? || result.undefined?
          options[:message] = result.message
          options[:trace] = result.backtrace&.join("\n")
        end
        StatusDetails.new(**options)
      end

      private

      def labels(test_case)
        feature_labels = %w[feature package suite].map { |name| Label.new(name, test_case.feature.name) }
        scenario_labels = %w[story testClass].map { |name| Label.new(name, test_case.name) }
        tag_labels = test_case.tags.map { |tag| Label.new("tag", tag.name.delete_prefix("@")) }

        feature_labels + scenario_labels + tag_labels
      end

      def parameters(test_case)
        test_case.source
          .detect { |it| it.is_a?(Cucumber::Core::Ast::ExamplesTable::Row) }&.values
          &.map { |value| Parameter.new("argument", value) }
      end

      def keyword(test_step)
        test_step.source.detect { |it| it.is_a?(Cucumber::Core::Ast::Step) }.keyword
      end
    end
  end
end
