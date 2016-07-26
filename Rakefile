require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'

task :default => [:test]

namespace :db do
  ENV['RACK_ENV'] ||= 'test'
  task :load_config do
    require 'sinatra/activerecord'
  end
end

task :test => ['db:schema:load']
Rake::TestTask.new do |t|
  t.libs = [ 'lib', 'config' ]
  t.pattern = 'test/**/*_spec.rb'
end

desc 'Build gem'
task :gem do
  system 'gem build correole.gemspec'
end

desc 'Publish gem'
task :publish => :gem do
  system "gem push correole-#{Correole::VERSION}.gem"
end
