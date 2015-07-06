ENV['RACK_ENV']  = 'test'

require 'rubygems'
require 'bundler'
require 'bundler/setup'

require_relative '../app'

require 'minitest/autorun'
require 'minitest/unit'
require 'shoulda/context'
require 'fakeweb'

ActiveSupport.test_order = :sorted

class Minitest::Test
  def setup
  end

  def teardown
  end
end
