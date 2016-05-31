Gem::Specification.new do |s|
  s.name        = 'correole'
  s.version     = '0.0.0'
  s.date        = '2016-05-30'
  s.summary     = 'A newsletter webservice'
  s.description = <<-EOF
Correole is a webservice that subscribes and unsubscribes readers from
a newsletter.
EOF
  s.authors     = ['Ruslan Ledesma Garza']
  s.email       = 'ruslanledesmagarza@gmail.com'
  s.homepage    = 'http://ruslanledesma.com/'
  s.license     = 'Copyright 2016 Ruslan Ledesma Garza'

  s.files       = ['lib/correole.rb']
  s.executables = ['correole']
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'thin', '~> 1.7'
  s.add_dependency 'sinatra-activerecord', '~> 2.0'
  s.add_dependency 'pg'
end
