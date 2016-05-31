ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'dependencies'

include Rack::Test::Methods

db = File.expand_path('../../correole.db', __FILE__)
File.delete db if File.exists? db
require File.expand_path '../../db/migrate.rb', __FILE__
