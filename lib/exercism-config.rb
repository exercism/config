require 'aws-sdk-dynamodb'
require 'aws-sdk-secretsmanager'
require 'octokit'
require 'mandate'
require 'ostruct'
require 'json'

require_relative 'exercism_config/environment'
require_relative 'exercism_config/determine_environment'
require_relative 'exercism_config/generate_aws_settings'
require_relative 'exercism_config/setup_dynamodb_client'
require_relative 'exercism_config/setup_ecr_client'
require_relative 'exercism_config/setup_s3_client'
require_relative 'exercism_config/retrieve_config'
require_relative 'exercism_config/retrieve_secrets'

require_relative 'exercism_config/version'
require_relative 'exercism/config'
require_relative 'exercism/secrets'

module Exercism
  class ConfigError < RuntimeError; end

  def self.env
    @env ||= ExercismConfig::DetermineEnvironment.()
  end

  def self.config
    @config ||= ExercismConfig::RetrieveConfig.()
  end

  def self.secrets
    @secrets ||= ExercismConfig::RetrieveSecrets.()
  end

  def self.dynamodb_client
    Aws::DynamoDB::Client.new(ExercismConfig::GenerateAwsSettings.())
  end

  def self.s3_client
    require 'aws-sdk-s3'
    Aws::S3::Client.new(
      ExercismConfig::GenerateAwsSettings.().merge(
        force_path_style: true
      )
    )
  end

  def self.ecr_client
    require 'aws-sdk-ecr'
    Aws::ECR::Client.new(ExercismConfig::GenerateAwsSettings.())
  end

  def self.octokit_client
    require 'octokit'

    access_token = ENV.fetch(
      "GITHUB_ACCESS_TOKEN",
      self.secrets.github_access_token
    )

    @octokit_client ||= Octokit::Client.new(
      access_token: access_token
    ).tap do |c|
      c.auto_paginate = true
    end
  end
end
