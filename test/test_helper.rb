ENV['RACK_ENV'] = 'test'
ENV['CONFIG_FILE'] = 'test.config.yml'

require 'minitest/autorun'
require 'rack/test'
require 'dependencies'
require 'thin'
require 'mini-smtp-server'

include Rack::Test::Methods

