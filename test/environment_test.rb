require 'test_helper'

module ExercismConfig
  class EnvironmentTest < Minitest::Test
    def test_development
      env = Environment.new(:development)

      assert env.development?
      assert_equal "development", env.to_s
      assert_equal "development", env.inspect
      assert_equal env, "development"
      assert_equal env, :development

      refute env.test?
      refute env.production?
      refute_equal env, "production"
    end

    def test_test
      env = Environment.new(:test)

      assert env.test?
      assert_equal "test", env.to_s
      assert_equal "test", env.inspect
      assert_equal env, "test"
      assert_equal env, :test

      refute env.development?
      refute env.production?
      refute_equal env, "production"
    end

    def test_production
      env = Environment.new(:production)

      assert env.production?
      assert_equal "production", env.to_s
      assert_equal "production", env.inspect
      assert_equal env, "production"
      assert_equal env, :production

      refute env.test?
      refute env.development?
      refute_equal env, "development"
    end

    def test_invalid_env
      assert_raises Exercism::ConfigError do
        Environment.new(:docker)
      end
    end
  end
end
