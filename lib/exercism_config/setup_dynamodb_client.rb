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
      ).select {|k,v|v}
      Aws::DynamoDB::Client.new(aws_settings)
    end

    private
    attr_reader :environment

    memoize
    def config_endpoint
      case Exercism.environment
      when :development, :test
        host = ENV["EXERCISM_DOCKER"] ? "dynamodb:8000" : "localhost:3039"
        "http://#{host}"
      else
        nil
      end
    end
  end
end
