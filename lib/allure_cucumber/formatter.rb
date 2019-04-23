# frozen_string_literal: true

require "cucumber-core"

module Allure
  class CucumberFormatter
    HOOK_HANDLERS = {
      "Before hook" => :start_prepare_fixture,
      "After hook" => :start_tear_down_fixture,
    }.freeze
    ALLURE_STATUS = {
      failed: Status::FAILED,
      skipped: Status::SKIPPED,
      passed: Status::PASSED,
    }.freeze

    def initialize(config)
      Allure::Config.output_dir = config.out_stream if config.out_stream.is_a?(String)
      config.on_event(:test_case_started, &method(:on_test_case_started))
      config.on_event(:test_step_started, &method(:on_test_step_started))
      config.on_event(:test_step_finished, &method(:on_test_step_finished))
      config.on_event(:test_case_finished, &method(:on_test_case_finished))
    end

    # Handle test case started event
    # @param [Cucumber::Core::Events::TestCaseStarted] event
    # @return [void]
    def on_test_case_started(event)
      lifecycle.start_test_container(TestResultContainer.new(name: test_case.name))
      lifecycle.start_test_case(AllureCucumberModel.test_result(event.test_case))
    end

    # Handle test step started event
    # @param [Cucumber::Core::Events::TestStepStarted] event
    # @return [void]
    def on_test_step_started(event)
      hook?(event.test_step) ? handle_hook_started : handle_step_started
    end

    # Handle test step finished event
    # @param [Cucumber::Core::Events::TestStepFinished] event
    # @return [void]
    def on_test_step_finished(event)
      update_block = proc do |step|
        step.stage = Stage::FINISHED
        step.status = ALLURE_STATUS.fetch(event.result.to_sym, Status::BROKEN)
        step.status_detail = AllureCucumberModel.status_detail(event.result)
      end
      step_type = hook?(event.test_step) ? "fixture" : "test_step"

      lifecycle.public_send("update_#{step_type}", &update_block)
      lifecycle.public_send("stop_#{step_type}")
    end

    # Handle test case finished event
    # @param [Cucumber::Core::Events::TestCaseFinished] event
    # @return [void]
    def on_test_case_finished(event)
      lifecycle.update_test_case do |test_case|
        test_case.stage = Stage::FINISHED
        test_case.status = ALLURE_STATUS.fetch(event.result.to_sym, Status::BROKEN)
        test_case.status_detail = AllureCucumberModel.status_detail(event.result)
      end 
      lifecycle.stop_test_case
      lifecycle.stop_test_container
    end

    private

    # Get thread specific lifecycle
    # @return [Allure::AllureLifecycle]
    def lifecycle
      Allure.lifecycle
    end

    def hook?(test_step)
      HOOK_HANDLERS.key?(test_step.text)
    end

    def handle_step_started(test_step)
      lifecycle.start_test_step(AllureCucumberModel.step_result(test_step))
    end

    def handle_hook_started(test_step)
      lifecycle.public_send(HOOK_HANDLERS[test_step.text], AllureCucumberModel.fixture_result(test_step))
    end
  end
end
