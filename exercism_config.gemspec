require_relative 'lib/exercism_config/version'

Gem::Specification.new do |spec|
  spec.name          = 'exercism-config'
  spec.version       = ExercismConfig::VERSION
  spec.authors       = ['Jeremy Walker']
  spec.email         = ['jez.walker@gmail.com']

  spec.summary       = 'Retrieves stored config for Exercism'
  spec.homepage      = 'https://exercism.io'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.6')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/exercism/config'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = %w[
    setup_exercism_config
    setup_exercism_local_aws
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-dynamodb', '~> 1.0'
  spec.add_dependency 'aws-sdk-secretsmanager', '~> 1.0'
  spec.add_dependency 'mandate'
  spec.add_dependency 'zeitwerk'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake', '~> 12.3'

  # This isn't a compulsary dependency
  # but can be used if someone puts it in their
  # own Gemfile when using this.
  spec.add_development_dependency 'aws-sdk-ecr'
  spec.add_development_dependency 'aws-sdk-s3'
  spec.add_development_dependency 'elasticsearch', '6.8.3'
  spec.add_development_dependency 'redis'
end
