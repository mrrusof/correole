class Configuration

  FEED = ENV['FEED'] || 'http://ruslanledesma.com/feed.xml'
  BASE_URI = ENV['BASE_URI'] || 'http://newsletter.ruslanledesma.com'
  SUBJECT = ENV['SUBJECT'] || '<%= title %> - <%= date %>'
  FROM = ENV['FROM'] || 'no-reply <no-reply@ruslanledesma.com>'

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

Mail.defaults do
  delivery_method :smtp, address: ENV['SMTP_SERVER'] || 'localhost', port: ENV['SMTP_PORT'] || 25
end
