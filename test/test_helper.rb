# We want to run these tests to simulate a production environment
# This is different to how running tests normally works.
ENV['EXERCISM_ENV'] = 'production'

# This must happen above the env require below
if ENV["CAPTURE_CODE_COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'exercism-config'
