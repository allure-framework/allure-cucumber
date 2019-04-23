# frozen_string_literal: true

module Allure
  class AllureCucumberModel
    class << self
      # Convert to allure test result
      # @param [Cucumber::Core::Test::Case] test_case
      # @return [TestResult]
      def test_result(test_case)
        TestResult.new(
          name: test_case.name,
          full_name: "#{test_case.feature.name}: #{test_case.name}",
          labels: labels(
            feature: test_case.feature.name,
            scenario: test_case.name,
            tags: test_case.tags,
          ),
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
        exception = result.instance_variable_get("@exception")
        StatusDetails.new(
          flaky: result.flaky?,
          message: exception&.message || nil,
          trace: exception&.backtrace&.join("\n") || nil,
        )
      end

      private

      def labels(feature:, scenario:, tags:)
        feature_labels = %w[feature package suite].map { |name| Label.new(name, feature) }
        scenario_labels = %w[story testClass].map { |name| Label.new(name, scenario) }
        tag_labels = tags.map { |tag| Label.new("tag", tag.name.delete_prefix("@")) }

        feature_labels + scenario_labels + tag_labels
      end

      def keyword(test_step)
        test_step.source.detect { |it| it.is_a?(Cucumber::Core::Ast::Step) }.keyword
      end
    end
  end
end
