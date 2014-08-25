# Allure Cucumber Adaptor

This repository contains Allure adaptor for [Cucumber](http://cukes.info/) framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'allure-cucumber'
```
And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install allure-cucumber
```

## Configuration

By default, Allure XML files are stored in `gen/allure-results`. To change this add the following in `features/support/env.rb` file:

```ruby
AllureCucumber.configure do |c|
   c.output_dir = "/output/dir"
end
```

## Usage

Put the following in your `features/support/env.rb` file:

```ruby
require 'allure-cucumber'
```

Use `--format AllureCucumber::Formatter` while running cucumber or add it to `cucumber.yml`

You can also [attach screenshots](https://github.com/allure-framework/allure-core/wiki/Glossary#attachment), logs or test data to [steps](https://github.com/allure-framework/allure-core/wiki/Glossary#test-step).

```ruby
# file: features/support/env.rb

include AllureCucumber::DSL

attach_file(title, file)
```

## How to generate report
This adapter only generates XML files containing information about tests. See [wiki section](https://github.com/allure-framework/allure-core/wiki#generating-report) on how to generate report.
