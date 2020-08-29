module ExercismConfig
  class DetermineEnvironment
    include Mandate

    def call
      env = ENV['EXERCISM_ENV'] || ENV['RAILS_ENV'] || ENV['APP_ENV']
      unless env
        env = Rails.env.to_s if Object.const_defined?(:Rails) && Rails.respond_to?(:env)
      end

      raise Exercism::ConfigError, 'No environment set - set one of EXERCISM_ENV, RAILS_ENV or APP_ENV' unless env

      Environment.new(env)
    end
  end
end
