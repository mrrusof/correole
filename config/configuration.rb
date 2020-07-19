DEFAULT_ENV = 'production'
DEFAULT_CONFIG_FILE = 'config.yml'

ENV['RACK_ENV'] ||= DEFAULT_ENV
ENV['CONFIG_FILE'] ||= File.expand_path "../#{DEFAULT_CONFIG_FILE}", __FILE__

class Configuration

  BOOLEAN_KEYS = [
    'QUIET',
    'DRY_RUN',
    'SMTP_TTLS'
  ]
  CONFIG_KEYS = [
    'DRY_RUN_EMAIL',
    'FEED',
    'UNSUBSCRIBE_URI',
    'CONFIRMATION_URI',
    'BASE_URI',
    'SUBJECT',
    'FROM',
    'HTML_TEMPLATE',
    'PLAIN_TEMPLATE',
    'SMTP_HOST',
    'SMTP_PORT',
    'SMTP_USER',
    'SMTP_PASS',
    'SMTP_AUTH',
  ] + BOOLEAN_KEYS

  class << self
    CONFIG_KEYS.each do |k|
      attr_accessor k.downcase.to_sym
    end
  end

  def self.load!

    YAML.load_file(ENV['CONFIG_FILE'])[ENV['RACK_ENV']].each_pair do |k, v|
      ENV[k.upcase] ||= v.to_s rescue abort("Cannot load configuration key #{k}.")
    end rescue qputs "Cannot load configuration file #{ENV['CONFIG_FILE']}. Using configuration given by environment."

    CONFIG_KEYS.each do |k|
      case k
      when *BOOLEAN_KEYS
        # Cannot store boolean values in ENV, thus this.
        self.send("#{k.downcase}=".to_sym, ENV[k] == 'true')
      when 'HTML_TEMPLATE', 'PLAIN_TEMPLATE'
        path = File.expand_path "../#{ENV[k]}", __FILE__
        template = File.read path rescue abort "Cannot load template #{path}."
        self.send("#{k.downcase}=".to_sym, template)
      when 'SMTP_USER', 'SMTP_PASS'
        # For user name and password, Mail interprets '' as an input.
        # It doesn't do the same with nil.
        self.send("#{k.downcase}=".to_sym, ENV[k] == '' ? nil : ENV[k])
      else
        self.send("#{k.downcase}=".to_sym, ENV[k])
      end
    end

    Mail.defaults do
      delivery_method :smtp,
      address:                Configuration.smtp_host,
      port:                   Configuration.smtp_port,
      user_name:              Configuration.smtp_user,
      password:               Configuration.smtp_pass,
      authentication:         Configuration.smtp_auth,
      enable_starttls_auto:   Configuration.smtp_ttls
    end

  end

end

Configuration.load!
