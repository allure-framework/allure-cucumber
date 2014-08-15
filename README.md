# AllureCucumber

Allure adaptor for [cucumber](http://cukes.info/). This is an experimental gem and very much a work in progress.

## Installation

Add this line to your application's Gemfile:

    gem 'allure-cucumber'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install allure-cucumber

## Usage

Use `--format AllureCucumber::Formatter` while running cucumber or add it to `cucumber.yml`

By default, allure artifacts are stored in `/allure/data`. To change this set `AllureCucumber::Config.output_dir` in your `env.rb` file.

You can also attach screenshots, logs or test data to steps 

```ruby
	# file: features/support/env.rb

	include AllureCucumber::DSL

	 attach_file(title, file)
```

