module ExercismConfig
  class RetrieveSecrets
    include Mandate

    def call
      return generate_mock if Exercism.env.test?

      retrieve_from_aws
    end

    private
    def generate_mock
      require 'erb'
      require 'yaml'

      secrets_file = File.expand_path('../../settings/secrets.yml', __dir__)
      secrets = YAML.safe_load(ERB.new(File.read(secrets_file)).result)

      Exercism::Secrets.new(secrets)
    end

    def retrieve_from_aws
      client = Aws::SecretsManager::Client.new(GenerateAwsSettings.())
      json = client.get_secret_value(secret_id: "config").secret_string
      Exercism::Secrets.new(JSON.parse(json))
    rescue StandardError => e
      raise Exercism::ConfigError, "Exercism's secrets could not be loaded: #{e.message}"
    end
  end
end
