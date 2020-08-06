module ExercismConfig
  class GenerateAwsSettings
    include Mandate

    def call
      {
        region: 'eu-west-2',
        profile: profile,
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
    def profile
      Exercism.env.production? ? nil : 'exercism_staging'
    end
  end
end
