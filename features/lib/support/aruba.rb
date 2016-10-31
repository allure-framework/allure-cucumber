require 'aruba/cucumber'

Aruba.configure do |config|
  # Such big values were added for debugging of the code into IDE
  config.exit_timeout = 6000
  config.io_wait_timeout = 6000
end