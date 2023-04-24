module ExercismConfig
  class GenerateAwsSettings
    include Mandate

    def call
      {
        region: 'eu-west-2',
        endpoint:,
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key
      }.select { |_k, v| v }
    end

    memoize
    def aws_access_key_id
      Exercism.env.production? ? nil : 'FAKE'
    end

    memoize
    def aws_secret_access_key
      Exercism.env.production? ? nil : 'FAKE'
    end

    memoize
    def endpoint
      return nil if Exercism.env.production?
      return "http://127.0.0.1:#{ENV['AWS_PORT']}" if Exercism.env.test? && ENV['EXERCISM_CI']

      "http://localhost:3040"
    end
  end
end
