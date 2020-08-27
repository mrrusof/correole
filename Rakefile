require 'sinatra/activerecord/rake'
require 'rake'
require 'rake/testtask'

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

desc 'Clean project'
task :clean do
  system <<~'EOS'
         rm -rf *.gem *.db
         find . -name '*~' -delete
         EOS
end

namespace :local do
  desc 'Runs correole in API mode'
  task :web do
    system 'bundle exec foreman start web'
  end
end
