module ExercismConfig
  class Retrieve
    include Mandate

    def call
      client = SetupDynamoDBClient.()

      resp = client.scan({table_name: "config"})
      items = resp.to_h[:items]
      data = items.each_with_object({}) do |item, h|
        h[item['id']] = item['value']
      end

      # Tweak things for dynamodb when we're running in test mode
      if Exercism.environment == :test
        %w{dynamodb_tooling_jobs_table}.each do |key|
          data[key] = "#{data[key]}-test"
        end
      end

      aws_settings = GenerateAwsSettings.()
      Exercism::Config.new(data, aws_settings)
    rescue Exercism::ConfigError
      raise
    rescue => e
      raise Exercism::ConfigError, "Exercism Config could not be loaded: #{e.message}"
    end

    private
    memoize
    def aws_client
      config = {
        region: 'eu-west-2',
        profile: profile,
        endpoint: endpoint,
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key
      }.select {|k,v|v}

      Aws::DynamoDB::Client.new(config)
    end
  end
end

