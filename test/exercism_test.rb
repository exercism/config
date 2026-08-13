require 'test_helper'

class ExercismTest < Minitest::Test
  def test_env_defined
    assert Exercism.env
  end

  def test_redis_clients_are_reused
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    assert_same Exercism.redis_cache_client, Exercism.redis_cache_client
  end

  def test_redis_clients_are_per_url
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    refute_same Exercism.redis_client("redis://localhost:6379/1"), Exercism.redis_client("redis://localhost:6379/2")
  end

  def test_redis_clients_are_rebuilt_after_fork
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    client = Exercism.redis_cache_client
    Process.stubs(pid: Process.pid + 1)

    refute_same client, Exercism.redis_cache_client
  end

  def test_cloudfront_client
    cloudfront_client = Exercism.cloudfront_client
    assert_equal "eu-west-2", cloudfront_client.config.region
  end

  def test_dynamodb_client
    dynamodb_client = Exercism.dynamodb_client
    assert_equal "eu-west-2", dynamodb_client.config.region
  end

  def test_ecr_client
    ecr_client = Exercism.ecr_client
    assert_equal "eu-west-2", ecr_client.config.region
  end

  def test_ses_client
    ses_client = Exercism.ses_client
    assert_equal "eu-west-2", ses_client.config.region
  end

  def test_octokit_client
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    octokit_client = Exercism.octokit_client
    assert octokit_client.auto_paginate
  end

  def test_octokit_graphql_client
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    octokit_graphql_client = Exercism.octokit_graphql_client
    assert octokit_graphql_client.auto_paginate
  end

  def test_opensearch_client
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    opensearch_client = Exercism.opensearch_client
    options = opensearch_client.instance_variable_get(:@transport).instance_variable_get(:@options)
    refute options[:transport_options][:ssl][:verify]
  end

  def test_discourse_client
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    discourse_client = Exercism.discourse_client
    assert "https://forum.exercism.org", discourse_client.host
  end
end
