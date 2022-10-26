require 'aws-sdk-dynamodb'
require 'aws-sdk-secretsmanager'
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
require_relative 'exercism/tooling_job'

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

  def self.redis_tooling_client
    Redis.new(url: config.tooling_redis_url)
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

  def self.opensearch_client
    require 'elasticsearch'

    # For now, we're using the ElasticSearch client, but this needs to be
    # changed to the OpenSearch client once it becomes available
    Elasticsearch::Client.new(
      url: ENV.fetch("OPENSEARCH_HOST", config.opensearch_host),
      user: ENV.fetch("OPENSEARCH_USER", Exercism.env.production? ? nil : "admin"),
      password: ENV.fetch("OPENSEARCH_PASSWORD", Exercism.env.production? ? nil : "admin"),
      transport_options: {
        ssl: {
          verify: Exercism.env.production?
        }
      }
    )
  end

  def self.discourse_client
    require 'discourse_api'

    DiscourseApi::Client.new("https://forum.exercism.org").tap do |client|
      client.api_key = ENV.fetch("DISCOURSE_API_KEY", Exercism.secrets.discourse_api_key)
      client.api_username = ENV.fetch("DISCOURSE_API_USERNAME", "system")
    end
  end
end
