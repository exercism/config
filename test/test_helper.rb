ENV["EXERCISM_ENV"] = "test"

gem "minitest"
require "minitest/autorun"
require 'minitest/unit'
require "mocha/minitest"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "exercism_config"

