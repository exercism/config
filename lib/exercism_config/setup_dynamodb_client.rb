module ExercismConfig
  class SetupDynamoDBClient
    include Mandate

    def call
      puts "[DEPRECATION] ExercismConfig::SetupDynamoDBClient.() is deprecated. Please use Exercism.dynamodb_client"

      Exercism.dynamodb_client
    end
  end
end
