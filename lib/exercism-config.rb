require 'aws-sdk-dynamodb'
require 'mandate'
require 'ostruct'
require 'json'

require_relative 'exercism_config/environment'
require_relative 'exercism_config/determine_environment'
require_relative 'exercism_config/generate_aws_settings'
require_relative 'exercism_config/setup_dynamodb_client'
require_relative 'exercism_config/setup_s3_client'
require_relative 'exercism_config/retrieve'
require_relative 'exercism_config/generate_aws_settings'
require_relative 'exercism_config/version'

require_relative 'exercism/config'

module Exercism
  class ConfigError < RuntimeError; end

  def self.env
    @env ||= ExercismConfig::DetermineEnvironment.()
  end

  def self.environment
    puts "Exercism.environment is deprecated. Use Exercism.env"
    env
  end

  def self.config
    @config ||= ExercismConfig::Retrieve.()
  end
end
