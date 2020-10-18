module ExercismConfig
  class SetupECRClient
    include Mandate

    def call
      aws_settings = GenerateAwsSettings.().merge(
        # endpoint: config_endpoint,

        # We don't want a profile for this AWS service
        # as we run it locally. But we do normally, so
        # we locally override this here.
        profile: nil
      ).select { |_k, v| v }

      Aws::ECR::Client.new(aws_settings)
    end
  end
end
