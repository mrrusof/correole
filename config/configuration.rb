class Configuration

  class << self
    attr_accessor :quiet
  end

  FEED = ENV['FEED'] || 'http://ruslanledesma.com/feed.xml'
  CONFIRMATION_URI = ENV['CONFIRMATION_URI'] || 'http://ruslanledesma.com/unsubscribed/'
  BASE_URI = ENV['BASE_URI'] || 'http://newsletter.ruslanledesma.com'
  SUBJECT = ENV['SUBJECT'] || '<%= title %>: newsletter for <%= date %>'
  FROM = ENV['FROM'] || '<%= title %> <no-reply@ruslanledesma.com>'

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
  delivery_method :smtp,
    address:                ENV['SMTP_HOST'] || 'localhost',
    port:                   ENV['SMTP_PORT'] || 25,
    user_name:              ENV['SMTP_USER'],
    password:               ENV['SMTP_PASS'],
    authentication:         ENV['SMTP_AUTH'],
    enable_starttls_auto:   ENV['SMTP_TTLS'] ? ENV['SMTP_TTLS'] == 'yes' : false
end
