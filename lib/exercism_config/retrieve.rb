module ExercismConfig
  class Retrieve
    include Mandate

    def call
      resp = aws_client.scan({table_name: "config"})
      items = resp.to_h[:items]
      data = items.each_with_object({}) do |item, h|
        h[item['id']] = item['value']
      end

      data[:retrieved] = true
      Exercism::Config.new(data)
    rescue => e
      p "No Exercism config retrieved"
      Exercism::Config.new(retrieved: false)
    end

    memoize
    def aws_client
      config = {region: 'eu-west-2'}
      config[:profile] = ENV["AWS_PROFILE"] if ENV["AWS_PROFILE"]
      Aws::DynamoDB::Client.new(config)
    end
  end
end

