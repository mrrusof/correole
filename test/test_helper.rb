ENV['RACK_ENV'] = 'test'
ENV['CONFIG_FILE'] = File.expand_path '../../config/config.yml', __FILE__

require 'minitest/autorun'
require 'rack/test'
require 'dependencies'
require 'thin'
require 'mini-smtp-server'

include Rack::Test::Methods

