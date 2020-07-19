require File.expand_path '../../test_helper.rb', __FILE__

describe 'Configuration' do

  describe '.load!' do

    let(:config) {
      {
        'QUIET' => 'false',
        'DRY_RUN' => 'false',
        'DRY_RUN_EMAIL' => 'test@mail.com',
        'FEED' => 'feed',
        'UNSUBSCRIBE_URI' => 'unsubscribe_uri',
        'CONFIRMATION_URI' => 'confirmation_uri',
        'BASE_URI' => 'base_uri',
        'SUBJECT' => 'subject',
        'FROM' => 'from',
        'HTML_TEMPLATE' => 'test.html.erb',
        'PLAIN_TEMPLATE' => 'test.txt.erb',
        'SMTP_HOST' => 'smtp_host',
        'SMTP_PORT' => 'smtp_port',
        'SMTP_USER' => 'smtp_user',
        'SMTP_PASS' => 'smtp_pass',
        'SMTP_AUTH' => 'smtp_auth',
        'SMTP_TTLS' => 'true'
      }
    }

    before do
      # Clear config file, configuration, and environment.
      @curr_config_file = ENV['CONFIG_FILE']
      @curr_env = {}
      ENV['CONFIG_FILE'] = nil
      Configuration::CONFIG_KEYS.each do |k|
        Configuration.send("#{k.downcase}=".to_sym, nil)
        @curr_env[k] = ENV[k]
      end
    end

    after do
      # Restore config file, configuration, and environment.
      ENV['CONFIG_FILE'] = @curr_config_file
      @curr_env.each_pair { |k, v| ENV[k] = v }
      Configuration.load!
    end

    def massage_config_param(k, v)
      case k
      when *Configuration::BOOLEAN_KEYS
        v = v == 'true'
      when 'HTML_TEMPLATE', 'PLAIN_TEMPLATE'
        file = File.expand_path "../../../config/#{v}", __FILE__
        v = File.read file
      when 'SMTP_USER', 'SMTP_PASS'
        v = v == '' ? nil : v
      end
      return v
    end

    describe 'file configuration' do

      before do
        ENV['CONFIG_FILE'] = File.expand_path '../../../config/test.config.yml', __FILE__
        Configuration.quiet = true
        Configuration.load!
      end

      it 'loads configuration' do
        yaml = YAML.load_file(ENV['CONFIG_FILE'])[ENV['RACK_ENV']]
        _(yaml.size).must_equal Configuration::CONFIG_KEYS.length
        yaml.each_pair do |k, v|
          k_method = k.downcase.to_sym
          k = k.upcase
          v = massage_config_param(k, v.to_s)
          assert Configuration.send(k_method) == v, "configuration key #{k} was not set to #{v}"
        end
      end

      it 'sets boolean values for boolean keys' do
        Configuration::BOOLEAN_KEYS.each do |k|
          v = Configuration.send k.downcase.to_sym
          _(v).must_equal !!v, "configuration key #{k} was not set to a boolean value"
        end
      end

    end

    describe 'environment configuration' do

      before do
        config.each_pair { |k, v| ENV[k] = v }
        Configuration.quiet = true
        Configuration.load!
      end

      it 'loads configuration' do
        _(config.size).must_equal Configuration::CONFIG_KEYS.length
        config.each_pair do |k, v|
          k_method = k.downcase.to_sym
          v = massage_config_param(k, v)
          _(Configuration.send(k_method)).must_equal v, "configuration key #{k} was not set to #{v}"
        end
      end

      it 'sets boolean values for boolean keys' do
        Configuration::BOOLEAN_KEYS.each do |k|
          v = Configuration.send k.downcase.to_sym
          _(v).must_equal !!v, "configuration key #{k} was not set to a boolean value"
        end
      end

    end

  end

end
