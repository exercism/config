module ExercismConfig
  class GenerateAwsSettings
    include Mandate

    def call
      {
        region: 'eu-west-2',
        profile: profile,
        access_key_id: aws_access_key_id,
        secret_access_key: aws_secret_access_key
      }.select {|k,v|v}
    end

    memoize
    def aws_access_key_id
      case Exercism.environment
      when :development, :test
        "FAKE"
      else 
        nil
      end
    end

    memoize
    def aws_secret_access_key
      case Exercism.environment
      when :development, :test
        "FAKE"
      else 
        nil
      end
    end

    memoize
    def profile
      case Exercism.environment
      when :production
        "exercism_staging"
      end
    end
  end
end
