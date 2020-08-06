module ExercismConfig
  class DetermineEnvironment
    include Mandate

    def call
      env = ENV['EXERCISM_ENV'] || ENV['RAILS_ENV'] || ENV['APP_ENV']
      raise Exercism::ConfigError, 'No environment set - set one of EXERCISM_ENV, RAILS_ENV or APP_ENV' unless env

      Environment.new(env)
    end
  end
end
