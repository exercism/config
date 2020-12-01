require 'test_helper'

class ExercismTest < Minitest::Test
  def test_env_defined
    assert Exercism.env
  end

  def test_dynamodb_client
    dynamodb_client = Exercism.dynamodb_client
    assert_equal "eu-west-2", dynamodb_client.config.region
  end

  def test_ecr_client
    ecr_client = Exercism.ecr_client
    assert_equal "eu-west-2", ecr_client.config.region
  end
end
