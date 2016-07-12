ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'dependencies'
require 'thin'
require 'mini-smtp-server'

include Rack::Test::Methods

