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

      settings_file = File.expand_path('../../settings/secrets.yml', __dir__)
      settings = YAML.safe_load(ERB.new(File.read(settings_file)).result)

      Exercism::Secrets.new(settings, {})
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
