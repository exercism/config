module ExercismConfig
  class SetupDynamoDBClient
    include Mandate

    def call
      aws_settings = GenerateAwsSettings.().merge(
        endpoint: config_endpoint,

        # We don't want a profile for this AWS service
        # as we run it locally. But we do normally, so
        # we locally override this here.
        profile: nil
      ).select { |_k, v| v }
      Aws::DynamoDB::Client.new(aws_settings)
    end

    private
    attr_reader :environment

    memoize
    def config_endpoint
      return nil unless %i[development test].include?(Exercism.environment)
      if Exercism.environment == :test && ENV['EXERCISM_CI']
        return "http://127.0.0.1:#{ENV['DYNAMODB_PORT']}"
      end

      host = ENV['EXERCISM_DOCKER'] ? 'dynamodb:8000' : 'localhost:3040'
      "http://#{host}"
    end
  end
end
