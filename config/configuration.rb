ENV['RACK_ENV'] ||= 'production'
ENV['CONFIG_FILE'] ||= 'config.yml'
config_file = File.expand_path "../#{ENV['CONFIG_FILE']}", __FILE__
YAML.load_file(config_file)[ENV['RACK_ENV']].each_pair do |k,v|
  ENV[k.upcase] ||= v.to_s rescue abort "Cannot load configuration key #{k}."
end rescue puts "Could not load configuration file #{config_file}."

class Configuration

  class << self
    attr_accessor :quiet
  end

  self.quiet = ENV['QUIET'] == 'true'
  FEED = ENV['FEED']
  CONFIRMATION_URI = ENV['CONFIRMATION_URI']
  BASE_URI = ENV['BASE_URI']
  SUBJECT = ENV['SUBJECT']
  FROM = ENV['FROM']
  file = File.expand_path "../#{ENV['HTML_TEMPLATE']}", __FILE__
  HTML_TEMPLATE = File.read file rescue abort "Cannot load html template #{ENV['HTML_TEMPLATE']}."
  file = File.expand_path "../#{ENV['PLAIN_TEMPLATE']}", __FILE__
  PLAIN_TEMPLATE = File.read file rescue abort "Cannot load plain template #{ENV['PLAIN_TEMPLATE']}."
end

Mail.defaults do
  delivery_method :smtp,
    address:                ENV['SMTP_HOST'],
    port:                   ENV['SMTP_PORT'],
    # For user name and password, Mail interprets '' as an input.
    # It doesn't do the same with nil.
    user_name:              ENV['SMTP_USER'] == '' ? nil : ENV['SMTP_USER'],
    password:               ENV['SMTP_PASS'] == '' ? nil : ENV['SMTP_PASS'],
    authentication:         ENV['SMTP_AUTH'],
    enable_starttls_auto:   ENV['SMTP_TTLS'] == 'true'
end
