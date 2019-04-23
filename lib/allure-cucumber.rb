# rubocop:disable Naming/FileName
# frozen_string_literal: true

require "allure_ruby_commons"

require "allure_cucumber/formatter"
require "allure_cucumber/config"

module Allure
  class << self
    # Set allure configuration
    # @yield [config]
    #
    # @yieldparam [Allure::CucumberConfig]
    # @return [void]
    def configure_cucumber
      yield(CucumberConfig)
    end
  end
end
# rubocop:enable Naming/FileName
