Gem::Specification.new do |s|
  s.name        = 'correole'
  s.version     = '0.0.0'
  s.date        = '2016-04-12'
  s.summary     = 'A newsletter webservice'
  s.description = <<-EOF
Correole is a newsletter webservice that provides functionality
for subscribing, unsubscribing, and sending newsletters.
EOF

  s.authors     = ['Ruslan Ledesma-Garza']
  s.email       = 'ruslanledesmagarza@gmail.com'
  s.homepage    = 'http://mrrusof.github.com/'
  s.license     = 'Ruslan Ledesma-Garza (c) 2016'

  s.files       = ['lib/correole.rb']
  s.executables = ['correole']
  s.add_dependency 'sinatra', '~> 1.4'
end
