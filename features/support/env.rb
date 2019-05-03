# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "allure-cucumber"

Allure.configure do |config|
  config.output_dir = "allure-results"
  config.tms_link_pattern = "http://www.jira.com/tms/{}"
  config.issue_link_pattern = "http://www.jira.com/issue/{}"
end

Before("@before_hook") do
end
