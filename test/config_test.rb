require 'test_helper'

module Exercism
  class ConfigTest < Minitest::Test
    def test_accessors
      config = Config.new({ 'foo' => 'bar' }, {})
      assert_equal 'bar', config.foo
    end

    def test_to_json
      config = Config.new({ 'foo' => 'bar' }, { k: 'v' })
      expected = {
        'foo' => 'bar',
        'aws_settings' => { 'k' => 'v' },
        'dynamodb_tooling_jobs_table' => nil,
        'dynamodb_tooling_language_groups_table' => nil
      }.to_json
      assert_equal expected, config.to_json
    end

    def test_test_suffix
      Exercism.stubs(env: ExercismConfig::Environment.new(:test))

      config = Config.new(
        {
          'foo' => 'bar',
          'dynamodb_tooling_jobs_table' => 'tooling_jobs',
          'dynamodb_tooling_language_groups_table' => 'tooling_language_groups'
        },
        {}
      )

      assert_equal 'tooling_jobs-test', config.dynamodb_tooling_jobs_table

      expected = {
        'foo' => 'bar',
        'dynamodb_tooling_jobs_table' => 'tooling_jobs-test',
        'dynamodb_tooling_language_groups_table' => 'tooling_language_groups-test',
        'aws_settings' => {}
      }.to_json
      assert_equal expected, config.to_json
    end
  end
end
