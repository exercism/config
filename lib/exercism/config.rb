module Exercism
  class Config < OpenStruct
    PROPS_WITH_TEST_SUFFIX = %i[
      dynamodb_tooling_jobs_table
    ].freeze

    def initialize(data, aws_settings)
      super(data)
      self.aws_settings = aws_settings
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
      end
      hash.to_json
    end
  end
end
