module ExercismConfig
  class Retrieve
    include Mandate

    def call
      return generate_mock if Exercism.environment == :test

      retrieve_from_dynamodb
    end

    private
    def generate_mock
      require 'erb'
      require 'yaml'

      filename = if ENV["EXERCISM_CI"]
                   'test-ci'
                 elsif ENV["EXERCISM_DOCKER"]
                   'test-docker'
                 else
                   'test-local'
                 end

      settings_file = File.expand_path("../../../settings/#{filename}.yml", __FILE__)
      settings = YAML.safe_load(ERB.new(File.read(settings_file)).result)

      Exercism::Config.new(settings, {})
    end

    def retrieve_from_dynamodb
      client = SetupDynamoDBClient.()

      resp = client.scan({ table_name: 'config' })
      items = resp.to_h[:items]
      data = items.each_with_object({}) do |item, h|
        h[item['id']] = item['value']
      end

      # Tweak things for dynamodb when we're running in test mode
      if Exercism.environment == :test
        %w[dynamodb_tooling_jobs_table].each do |key|
          data[key] = "#{data[key]}-test"
        end
      end

      aws_settings = GenerateAwsSettings.()
      Exercism::Config.new(data, aws_settings)
    rescue Exercism::ConfigError
      raise
    rescue StandardError => e
      raise Exercism::ConfigError, "Exercism Config could not be loaded: #{e.message}"
    end

    memoize
    def aws_client
      config = {
        region: 'eu-west-2',
        profile: profile,
        endpoint: endpoint,
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key
      }.select { |_k, v| v }

      Aws::DynamoDB::Client.new(config)
    end
  end
end
