class Configuration

  FEED = 'http://ruslanledesma.com/feed.xml'
  BASE_URI = 'http://newsletter.ruslanledesma.com'
  SUBJECT = '<%= title %> - <%= date %>'
  FROM = 'no-reply <no-reply@ruslanledesma.com>'

  HTML_TEMPLATE = <<-EOF
<html>
  <body>
    <h1>WIP: HTML template</h1>
  </body>
</html>
EOF

  PLAIN_TEMPLATE = <<-EOF
WIP: plain template
EOF

end
