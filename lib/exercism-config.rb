require "zeitwerk"
loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.inflector.inflect("exercism-config" => "ExercismConfig")
loader.inflector.inflect("version" => "VERSION")
loader.setup

require 'aws-sdk-dynamodb'
require 'aws-sdk-secretsmanager'
require 'mandate'
require 'ostruct'
require 'json'

# require_relative 'exercism_config/environment'
# require_relative 'exercism_config/determine_environment'
# require_relative 'exercism_config/generate_aws_settings'
# require_relative 'exercism_config/setup_dynamodb_client'
# require_relative 'exercism_config/setup_ecr_client'
# require_relative 'exercism_config/setup_s3_client'
# require_relative 'exercism_config/retrieve_config'
# require_relative 'exercism_config/retrieve_secrets'

# require_relative 'exercism_config/version'
# require_relative 'exercism/config'
# require_relative 'exercism/secrets'
# require_relative 'exercism/tooling_job'
#
module ::ExercismConfig
end
