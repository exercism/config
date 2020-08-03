require 'test_helper'

class RetrieveTest < Minitest::Test
  def test_config_is_set
    Aws::DynamoDB::Client.expects(:new).returns(client)

    assert ExercismConfig::Retrieve.()
  end

  def test_config_sets_if_lookup_fails
    assert_raises Exercism::ConfigError do
      Aws::DynamoDB::Client.expects(:new).raises(RuntimeError)
      ExercismConfig::Retrieve.()
    end
  end

  def test_config_for_production
    Exercism.stubs(environment: :production)

    Aws::DynamoDB::Client.expects(:new).with(
      region: 'eu-west-2'
    ).returns(client)

    assert ExercismConfig::Retrieve.()
  end

  def test_config_for_development
    Exercism.stubs(environment: :development)

    Aws::DynamoDB::Client.expects(:new).with(
      region: 'eu-west-2',
      endpoint: 'http://localhost:3040',
      access_key_id: 'FAKE',
      secret_access_key: 'FAKE'
    ).returns(client)

    assert ExercismConfig::Retrieve.()
  end

  def client
    resp = mock(to_h: { items: [] })
    mock(scan: resp)
  end
end
