require 'test_helper'

class ExercismConfigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExercismConfig::VERSION
  end

  def test_config_gets_set
    config = mock
    ExercismConfig::Retrieve.expects(:call).returns(config)
    assert_equal config, Exercism.config
  end
end
