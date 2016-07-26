require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'

ENV['RACK_ENV'] ||= 'test'

task :default => [:test]

namespace :db do
  task :load_config do
    require 'sinatra/activerecord'
  end
end

Rake::TestTask.new :test => 'db:schema:load' do |t|
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
