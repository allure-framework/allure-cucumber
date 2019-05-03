# frozen_string_literal: true

require File.expand_path("lib/allure_cucumber/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "allure-cucumber"
  spec.version = Allure::AllureCucumber::Version::STRING
  spec.authors = ["Andrejs Cunskis"]
  spec.email = ["andrejs.cunskis@gmail.com"]
  spec.summary = "allure_cucumber:#{Allure::AllureCucumber::Version::STRING}"
  spec.description = %(Adaptor to use Allure framework with cucumber)
  spec.homepage = "http://allure.qatools.ru"
  spec.license = "Apache-2.0"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cucumber" , "~> 3.1"
  spec.add_dependency "allure-ruby-commons", "~> 2.10.0.beta1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rubocop", "~> 0.67"
  spec.add_development_dependency "rubocop-performance", "~> 1.1"
  spec.add_development_dependency "pry", "~> 0.12"
  spec.add_development_dependency "solargraph", "~> 0.32"
  spec.add_development_dependency "rspec", "~> 3.8"
end
