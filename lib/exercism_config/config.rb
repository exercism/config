module ExercismConfig
  class Config < OpenStruct
    def to_json
      to_h.to_json
    end
  end
end
