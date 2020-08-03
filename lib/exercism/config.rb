module Exercism
  class Config < OpenStruct
    def initialize(data, aws_settings)
      super(data)
      self.aws_settings = aws_settings
    end

    def to_json(*_args)
      to_h.to_json
    end
  end
end
