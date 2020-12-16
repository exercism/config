module Exercism
  class Config < OpenStruct
    PROPS_WITH_TEST_SUFFIX = %i[
      dynamodb_tooling_jobs_table
      dynamodb_tooling_language_groups_table
    ].freeze

    def initialize(data, aws_settings)
      super(data)
      self.aws_settings = aws_settings
    end

    def method_missing(name, *args)
      super.tap do |val|
        next unless val.nil?

        keys = to_h.keys
        raise NoMethodError unless keys.include?(name.to_s) || keys.include?(name.to_sym)
      end
    end

    def respond_to_missing?(*args)
      super
      true
    rescue NoMethodError
      false
    end

    PROPS_WITH_TEST_SUFFIX.each do |prop|
      define_method prop do
        Exercism.env.test? ? "#{super()}-test" : super()
      end
    end

    def to_json(*_args)
      hash = to_h
      PROPS_WITH_TEST_SUFFIX.each do |prop|
        hash[prop] = send(prop)
      rescue NoMethodError
        # We don't want to show nil or empty string values in the JSON output
      end
      hash.to_json
    end
  end
end
