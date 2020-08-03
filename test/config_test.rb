require 'test_helper'

module Exercism
  class ConfigTest < Minitest::Test
    def test_accessors
      config = Config.new({ 'foo' => 'bar' }, {})
      assert_equal 'bar', config.foo
    end

    def test_to_json
      config = Config.new({ 'foo' => 'bar' }, { k: 'v' })
      expected = {
        'foo' => 'bar',
        'aws_settings' => { 'k' => 'v' }
      }.to_json
      assert_equal expected, config.to_json
    end
  end
end
