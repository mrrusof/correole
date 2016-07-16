DEFAULT_ENV = 'production'
DEFAULT_CONFIG_FILE = 'config.yml'

ENV['RACK_ENV'] ||= DEFAULT_ENV
ENV['CONFIG_FILE'] ||= DEFAULT_CONFIG_FILE

class Configuration

  CONFIG_KEYS = [
    'QUIET',
    'FEED',
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
    'SMTP_TTLS' ]

  class << self
    CONFIG_KEYS.each do |k|
      attr_accessor k.downcase.to_sym
    end
  end

  def self.load!

    config_file = File.expand_path "../#{ENV['CONFIG_FILE']}", __FILE__
    YAML.load_file(config_file)[ENV['RACK_ENV']].each_pair do |k, v|
      ENV[k.upcase] ||= v.to_s rescue abort "Cannot load configuration key #{k}."
    end rescue qputs "Could not load configuration file #{config_file}."

    CONFIG_KEYS.each do |k|
      case k
      when 'QUIET', 'SMTP_TTLS'
        # Cannot store boolean values in ENV, thus this.
        self.send("#{k.downcase}=".to_sym, ENV[k] == 'true')
      when 'HTML_TEMPLATE', 'PLAIN_TEMPLATE'
        file = File.expand_path "../#{ENV[k]}", __FILE__
        template = File.read file rescue abort "Cannot load template #{ENV[k]}."
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
