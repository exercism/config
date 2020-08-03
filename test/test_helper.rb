# We want to run these tests to simulate a production environment
# This is different to how running tests normally works.
ENV['EXERCISM_ENV'] = 'production'

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'exercism_config'
