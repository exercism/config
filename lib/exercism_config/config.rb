module ExercismConfig
  class Config < SimpleDelegator
    def to_json
      to_h.to_json
    end
  end
end
