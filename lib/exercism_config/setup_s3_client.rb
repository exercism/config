module ExercismConfig
  class SetupS3Client
    include Mandate

    def call
      puts "[DEPRECATION] ExercismConfig::SetupS3Client.() is deprecated. Please use Exercism.s3_client"

      Exercism.s3_client
    end
  end
end
