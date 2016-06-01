require 'sinatra/base'
require 'active_record'

ENV["RACK_ENV"] ||= 'development'

puts "Environment is #{ENV['RACK_ENV']}\n"

database_file = File.expand_path '../../config/database.yml', __FILE__
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(database_file)).result)
ActiveRecord::Base.establish_connection

ActiveRecord::Migration.create_table :subscribers do |t|
  t.string :email
  t.index :email, unique: true
  t.timestamps null: false
end
