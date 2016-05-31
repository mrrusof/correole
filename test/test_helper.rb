ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'active_record'
require File.expand_path '../../lib/correole.rb', __FILE__
require File.expand_path '../../lib/subscriber.rb', __FILE__

include Rack::Test::Methods

db = File.expand_path('../../correole.db', __FILE__)
File.delete db if File.exists? db
require File.expand_path '../../db/migrate.rb', __FILE__

