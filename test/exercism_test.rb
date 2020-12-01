require 'test_helper'

class ExercismTest < Minitest::Test
  def test_env_defined
    assert Exercism.env
  end
end
