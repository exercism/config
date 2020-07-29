module ExercismConfig
  class DetermineEnvironment
    include Mandate

    def call
      env = ENV["EXERCISM_ENV"] || ENV["RAILS_ENV"] || ENV["APP_ENV"]
      raise Exercism::ConfigError, "No environment set - set one of EXERCISM_ENV, RAILS_ENV or APP_ENV" unless env

      unless %w[development test production].include?(env)
        raise Exercism::ConfigError, "environments must be one of development test production. Got #{env}"
      end

      env.to_sym
    end
  end
end
