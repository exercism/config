require "exercism_config/version"
require 'aws-sdk-dynamodb'
require 'mandate'
require "ostruct"

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module ExercismConfig
  def self.config
    @config ||= Retrieve.()
  end
end
