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

  def self.redis_tooling_client = redis_client(config.tooling_redis_url)
  def self.redis_git_cache_client = redis_client(config.git_cache_redis_url)
  def self.redis_cache_client = redis_client(config.cache_redis_url)

  def self.redis_client(url)
    require 'redis'
    require 'redis-clustering'

    if Exercism.env.development? || Exercism.env.test?
      Redis.new(url:)
    else
      Redis::Cluster.new(nodes: [url])
    end
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

  def self.cloudwatch_logs_client
    require 'aws-sdk-cloudwatchlogs'
    Aws::CloudWatchLogs::Client.new(ExercismConfig::GenerateAwsSettings.())
  end

  def self.cloudfront_client
    require 'aws-sdk-cloudfront'
    Aws::CloudFront::Client.new(ExercismConfig::GenerateAwsSettings.())
  end

  def self.ses_client
    require 'aws-sdk-sesv2'
    Aws::SESV2::Client.new(ExercismConfig::GenerateAwsSettings.())
  end

  def self.octokit_client
    require 'octokit'

    access_token = ENV.fetch(
      "GITHUB_ACCESS_TOKEN",
      self.secrets.github_access_token
    )

    @octokit_client ||= Octokit::Client.new(access_token:).tap do |c|
      c.auto_paginate = true
    end
  end

  def self.octokit_graphql_client
    require 'octokit'

    access_token = ENV.fetch(
      "GITHUB_GRAPHQL_READONLY_ACCESS_TOKEN",
      self.secrets.github_graphql_readonly_access_token
    )

    @octokit_graphql_client ||= Octokit::Client.new(access_token:).tap do |c|
      c.auto_paginate = true
    end
  end

  def self.opensearch_client
    require 'opensearch'

    # For now, we're using the ElasticSearch client, but this needs to be
    # changed to the OpenSearch client once it becomes available
    OpenSearch::Client.new(
      host: ENV.fetch("OPENSEARCH_HOST", config.opensearch_host),
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

  def self.mongodb_client
    require 'mongo'
    Mongo::Client.new(
      self.config.mongodb_url,
      database: self.config.mongodb_database_name
    )
  end

  def self.openai_client
    require 'openai'

    @openai_client ||= OpenAI::Client.new(access_token: self.secrets.openai_api_key)
  end
end
