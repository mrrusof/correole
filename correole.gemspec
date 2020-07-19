require File.expand_path '../lib/correole/version.rb', __FILE__

Gem::Specification.new do |s|
  s.name        = 'correole'
  s.version     = Correole::VERSION
  s.date        = Correole::DATE
  s.summary     = 'A newsletter webservice'
  s.description = <<-EOF
Correole is a webservice that subscribes and unsubscribes readers from
a newsletter.
EOF
  s.authors     = ['Ruslan Ledesma Garza']
  s.email       = 'ruslanledesmagarza@gmail.com'
  s.homepage    = 'http://ruslanledesma.com/'
  s.license     = 'MIT'

  s.files          = `find config lib db/migrate`.split($\).
                     keep_if { |f| f[-3..-1] == '.rb'}
  [ 'database.yml',
    'example.config.yml',
    'production.html.erb',
    'production.txt.erb',
    'test.config.yml',
    'test.html.erb',
    'test.txt.erb' ].each { |f| s.files << "config/#{f}" }
  s.files          << 'bin/correole'
  s.require_paths  = ['config', 'lib']
  s.executables    = ['correole']

  s.add_dependency 'sinatra', '~> 2.0'
  s.add_dependency 'thin', '~> 1.7'
  s.add_dependency 'sinatra-activerecord', '~> 2.0'
  s.add_dependency 'activerecord', '~> 6.0'
  s.add_dependency 'activesupport', '~> 6.0'
  s.add_dependency 'mail', '~> 2.7'
  s.add_dependency 'pg', '~> 0'
  s.add_development_dependency 'sqlite3', '~> 1.4'
  s.add_development_dependency 'minitest', '~> 5.14'
  s.add_development_dependency 'rack-test', '~> 1.1'
  s.add_development_dependency 'mini-smtp-server', '~> 0'
  s.add_development_dependency 'gserver', '~> 0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.required_ruby_version = '~> 2.7.1'
end
