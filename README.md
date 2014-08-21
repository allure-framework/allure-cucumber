# Allure Cucumber Adaptor

This repository contains Allure adaptor for [Cucumber](http://cukes.info/) framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'allure-cucumber'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install allure-cucumber

## Usage

Put the following in your `features/support/env.rb` file

```ruby
require 'allure-cucumber'
```

Use `--format AllureCucumber::Formatter` while running cucumber or add it to `cucumber.yml`

## Advanced options

By default, Allure artifacts are stored in `gen/allure-results`. To change this add the following in `features/support/env.rb` file

```ruby
AllureCucumber.configure do |c|
   c.output_dir = "/output/dir"
end
```

You can also attach screenshots, logs or test data to steps 

```ruby
# file: features/support/env.rb

include AllureCucumber::DSL

attach_file(title, file)
```

