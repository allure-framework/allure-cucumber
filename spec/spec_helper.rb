# frozen_string_literal: true

require "rspec"
require "cucumber"
require "allure-ruby-commons"
require "allure-cucumber"
require "digest"
require "pry"

def run_cucumber_cli(feature)
  configuration = Cucumber::Cli::Configuration.new.tap do |config|
    config.parse!([feature, "--format", "Allure::CucumberFormatter"])
  end
  runtime = Cucumber::Runtime.new.tap do |run|
    run.configure(configuration)
  end

  runtime.run!
end
