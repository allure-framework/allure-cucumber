# frozen_string_literal: true

require "cucumber"
require "cucumber/core"
require "allure-cucumber"

Allure.configure do |config|
  config.tms_link_pattern = "http://www.jira.com/tms/{}"
  config.issue_link_pattern = "http://www.jira.com/issue/{}"
end

Before("@before") do
end

Before("@broken_hook") do
  raise Exception.new("Broken hook!")
end

After("@after") do
end
