require 'test_helper'

class ExercismTest < Minitest::Test
  def test_env_defined
    assert Exercism.env
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

  def test_redis_pool_is_reused_between_calls
    pool = Exercism::RedisPool.for(:test_reused) { build_test_redis_client }
    assert_same pool, Exercism::RedisPool.for(:test_reused) { build_test_redis_client }
  end

  def test_redis_pool_is_separate_per_key
    refute_same(
      Exercism::RedisPool.for(:test_key_one) { build_test_redis_client },
      Exercism::RedisPool.for(:test_key_two) { build_test_redis_client }
    )
  end

  def test_redis_pool_is_rebuilt_after_fork
    pool = Exercism::RedisPool.for(:test_forked) { build_test_redis_client }

    Process.stubs(pid: Process.pid + 1)
    refute_same pool, Exercism::RedisPool.for(:test_forked) { build_test_redis_client }
  end

  def test_redis_client_is_pooled_rather_than_rebuilt
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))

    assert_same Exercism.redis_tooling_client, Exercism.redis_tooling_client
    refute_same Exercism.redis_tooling_client, Exercism.redis_cache_client
  end

  def test_redis_pool_size_is_configurable
    assert_equal Exercism::RedisPool::DEFAULT_SIZE, Exercism::RedisPool.size

    ENV['EXERCISM_REDIS_POOL_SIZE'] = '17'
    assert_equal 17, Exercism::RedisPool.size
  ensure
    ENV.delete('EXERCISM_REDIS_POOL_SIZE')
  end

  private
  def build_test_redis_client = Redis.new(url: 'redis://localhost:6379')
end
