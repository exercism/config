require "exercism_config/version"
require 'aws-sdk-dynamodb'
require 'mandate'
require "ostruct"
require 'json'

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Exercism
  def self.config
    @config ||= ExercismConfig::Retrieve.()
  end
end
