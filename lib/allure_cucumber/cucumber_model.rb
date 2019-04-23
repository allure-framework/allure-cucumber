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
        )
      end

      # Convert to allure step result
      # @param [Cucumber::Core::Test::Step] test_step
      # @return [StepResult]
      def step_result(test_step)
        StepResult.new(name: test_step.text)
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
      def status_detail(result)
        exception = result.instance_variable_get("@exception")
        StatusDetails.new(
          flaky: result.flaky?,
          message: exception&.message || nil,
          trace: exception&.full_message || nil,
        )
      end
    end
  end
end
