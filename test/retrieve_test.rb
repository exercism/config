require "test_helper"

class RetrieveTest < Minitest::Test
  def test_config_is_set
    resp = mock(to_h: {items: []})
    client = mock(scan: resp)
    Aws::DynamoDB::Client.expects(:new).returns(client)

    config = ExercismConfig::Retrieve.()
    assert config.retrieved
  end

  def test_config_sets_if_lookup_fails
    config = ExercismConfig::Retrieve.()
    refute config.retrieved
  end
end

