ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'dependencies'

include Rack::Test::Methods

