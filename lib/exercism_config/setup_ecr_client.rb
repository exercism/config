module ExercismConfig
  class SetupECRClient
    include Mandate

    def call
      puts "[DEPRECATION] ExercismConfig::SetupECRClient.() is deprecated. Please use Exercism.ecr_client"

      Exercism.ecr_client
    end
  end
end
