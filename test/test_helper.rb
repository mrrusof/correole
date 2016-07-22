ENV['RACK_ENV'] = 'test'
ENV['CONFIG_FILE'] = 'test.config.yml'
ENV['N'] ||= '4'

require 'minitest/autorun'
require 'minitest/profile'
require 'rack/test'
require 'dependencies'
require 'thin'
require 'mini-smtp-server'

include Rack::Test::Methods

