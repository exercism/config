module ExercismConfig
  class SetupS3Client
    include Mandate

    def call
      require 'aws-sdk-s3'

      aws_settings = GenerateAwsSettings.().merge(
        endpoint: config_endpoint,
        force_path_style: true,

        # We don't want a profile for this AWS service
        # as we run it locally. But we do normally, so
        # we locally override this here.
        profile: nil
      ).select { |_k, v| v }
      Aws::S3::Client.new(aws_settings)
    end

    private
    memoize
    def config_endpoint
      return nil if Exercism.env.production?
      return "http://127.0.0.1:#{ENV['S3_PORT']}" if Exercism.env.test? && ENV['EXERCISM_CI']

      host = ENV['EXERCISM_DOCKER'] ? 's3:9090' : 'localhost:3041'
      "http://#{host}"
    end
  end
end
