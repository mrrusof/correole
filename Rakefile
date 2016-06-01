require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'

namespace :db do
  task :load_config do
    require 'sinatra/activerecord'
  end
end

Rake::TestTask.new do |t|
  t.libs = [ 'lib', 'config' ]
  t.pattern = 'test/*/*_spec.rb'
end
