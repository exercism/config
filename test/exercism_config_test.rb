require "test_helper"

class ExercismConfigTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExercismConfig::VERSION
  end
end
