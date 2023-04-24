# We want to run these tests to simulate a production environment
# This is different to how running tests normally works.
ENV['EXERCISM_ENV'] = 'production'

# This must happen above the env require below
if ENV["CAPTURE_CODE_COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'

require 'aws-sdk-s3'
require 'redis'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'exercism-config'

class Minitest::Test
  def upload_to_s3(bucket, key, body) # rubocop:disable Naming/VariableNumber
    Exercism.s3_client.put_object(
      bucket:,
      key:,
      body:,
      acl: 'private'
    )
  end
end
