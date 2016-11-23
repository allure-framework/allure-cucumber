# -*- encoding: utf-8 -*-
require File.expand_path('../lib/allure-cucumber/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "allure-cucumber"
  spec.version       = AllureCucumber::Version::STRING
  spec.authors       = ["Imran Khan"]
  spec.email         = ["9ikhan@gmail.com"]
  spec.summary       = "allure-cucumber-#{AllureCucumber::Version::STRING}"
  spec.description   = %q{Adaptor to use Allure framework with cucumber}
  spec.homepage      = "http://allure.qatools.ru"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'cucumber' , '>= 2.0.0'
  spec.add_dependency 'allure-ruby-adaptor-api'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "aruba", '~> 0.14.2'

end
