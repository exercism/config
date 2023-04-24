require 'test_helper'
require 'erb'
require 'yaml'

class RetrieveTest < Minitest::Test
  def test_config_is_set
    Aws::DynamoDB::Client.expects(:new).returns(client)

    assert ExercismConfig::RetrieveConfig.()
  end

  def test_config_sets_if_lookup_fails
    assert_raises Exercism::ConfigError do
      Aws::DynamoDB::Client.expects(:new).raises(RuntimeError)
      ExercismConfig::RetrieveConfig.()
    end
  end

  def test_config_for_production
    Exercism.stubs(env: ExercismConfig::Environment.new(:production))

    Aws::DynamoDB::Client.expects(:new).with({
                                               region: 'eu-west-2'
                                             }).returns(client)

    assert ExercismConfig::RetrieveConfig.()
  end

  # This can depend on the situation that the test is
  # being executed within
  def test_config_for_development
    Exercism.stubs(env: ExercismConfig::Environment.new(:development))
    config = ExercismConfig::RetrieveConfig.()
    assert_includes %w[
      mysql
      localhost
      127.0.0.1
    ], config.mysql_master_endpoint
  end

  # This can depend on the situation that the test is
  # being executed within
  def test_config_for_test
    Exercism.stubs(env: ExercismConfig::Environment.new(:test))
    config = ExercismConfig::RetrieveConfig.()
    assert_includes %w[
      mysql
      localhost
      127.0.0.1
    ], config.mysql_master_endpoint
  end

  def client
    resp = mock(to_h: { items: [] })
    mock(scan: resp)
  end
end
