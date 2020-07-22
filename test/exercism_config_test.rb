require "test_helper"

class ExercismConfigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExercismConfig::VERSION
  end

  def test_config_is_set
    resp = mock(to_h: {items: []})
    client = mock(scan: resp)
    Aws::DynamoDB::Client.expects(:new).returns(client)

    assert Exercism.config
  end
end
