require File.expand_path '../../test_helper.rb', __FILE__
require 'thin'
require 'mini-smtp-server'

describe 'Command `correole`' do

  let(:port) { 5987 }
  let(:timeout) { 10 }
  let(:root) { File.expand_path '../../../', __FILE__ }
  let(:cmd) { "PORT=#{port} ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole" }

  it "runs API" do
    spawn(cmd, [ :err, :out ] => '/dev/null')
    stop = Time.now.to_i + timeout
    while ! system("lsof -i TCP:#{port}", [ :err, :out ] => '/dev/null') && Time.now.to_i < stop
      print '#'
      sleep 0.25
    end
    assert system("lsof -i TCP:#{port}", [ :err, :out ] => '/dev/null'), "Correole did not start within #{timeout} seconds."
    pid = %x( lsof -i TCP:#{port} -F p )[1..-1]
    Process.kill(9, pid.to_i)
  end

end

class FeedServer < Sinatra::Base

  set :server, :thin

  before do
    content_type 'application/rss+xml'
  end

  get '/feed.xml' do
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Ruslan writes code</title>
    <description>Uebung macht den Meister.</description>
    <link>http://ruslanledesma.com/</link>
    <atom:link href="http://ruslanledesma.com/feed.xml" rel="self" type="application/rss+xml"/>
    <pubDate>Sun, 10 Jul 2016 00:18:32 +0000</pubDate>
    <lastBuildDate>Sun, 10 Jul 2016 00:18:32 +0000</lastBuildDate>
    <generator>Jekyll v3.1.6</generator>
      <item>
        <title>title1</title>
        <description>description1</description>
        <pubDate>Fri, 17 Jun 2016 00:00:00 +0000</pubDate>
        <link>http://ruslanledesma.com/uri1_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri1_1468301761</guid>
      </item>
      <item>
        <title>title2</title>
        <description>description2</description>
        <pubDate>Thu, 26 May 2016 00:00:00 +0000</pubDate>
        <link>http://ruslanledesma.com/uri2_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri2_1468301761</guid>
      </item>
      <item>
        <title>title3</title>
        <description>description3</description>
        <pubDate>Thu, 26 May 2016 00:00:00 +0000</pubDate>
        <link>http://ruslanledesma.com/uri3_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri3_1468301761</guid>
      </item>
      <item>
        <title>title4</title>
        <description>description4</description>
        <pubDate>Thu, 26 May 2016 00:00:00 +0000</pubDate>
        <link>http://ruslanledesma.com/uri4_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri4_1468301761</guid>
      </item>
      <item>
        <title>title5</title>
        <description>description5</description>
        <pubDate>Sat, 23 Apr 2016 00:00:00 +0000</pubDate>
        <link>http://ruslanledesma.com/uri5_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri5_1468301761</guid>
      </item>
      <item>
        <title>title6</title>
        <description>description6</description>
        <link>http://ruslanledesma.com/uri6_1468301761</link>
        <guid isPermaLink="true">http://ruslanledesma.com/uri6_1468301761</guid>
      </item>
  </channel>
</rss>
EOF
  end
end

class SmtpServer < MiniSmtpServer

  attr_accessor :received

  def initialize(port, host, workers)
    super(port, host, workers)
    @received = []
  end

  def new_message_event(message_hash)
    @received << message_hash
  end
end

describe 'Command `correole send`' do

  let(:root) { File.expand_path '../../../', __FILE__ }
  let(:cmd) { "RACK_ENV=test ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole send" }
  let(:config_file) { "#{root}/config/configuration.rb" }
  let(:bak_file) { "#{root}/config/configuration.rb.bak" }
  let(:http_port) { 9090 }
  let(:smtp_port) { 9191 }
  let(:timeout) { 10 }
  let(:quiet) { true }
  let(:recipient) { 'ruslan@localhost' }

  before do
    # Configure only one subscriber
    Subscriber.destroy_all
    s = Subscriber.new(email: recipient)
    s.save

    # Point program to fake feed and to smtp server
    FileUtils.cp config_file, bak_file
    config = File.read(config_file)
    config.gsub!(/FEED = .+/, "FEED = 'http://localhost:#{http_port}/feed.xml'")
    config = <<-EOF
#{config}

require 'mail'

Mail.defaults do
  delivery_method :smtp, address: 'localhost', port: #{smtp_port}
end
EOF
    File.write(config_file, config)

    # Catch mail
    @smtp_server = SmtpServer.new(smtp_port, 'localhost', 1)
    @smtp_server.start

    # Provide feed
    FeedServer.set :port, http_port
    @curr_stdout = $stdout
    @curr_stderr = $stderr
    if quiet
      $stdout = StringIO.new
      $stderr = StringIO.new
      Thin::Logging.silent = true
    end
    Thread.new { FeedServer.run! }
    stop = Time.now.to_i + timeout
    while ! FeedServer.running? && Time.now.to_i < stop
      print '#'
      sleep 0.25
    end
  end

  after do
    @smtp_server.stop

    FeedServer.quit!

    $stdout = @curr_stdout
    $stderr = @curr_stderr

    # Restore configuration
    FileUtils.mv bak_file, config_file
  end

  it 'does not fail' do
    assert system(cmd), "command `#{cmd}` fails"
  end

  it 'sends out only one email' do
    system(cmd)
    @smtp_server.received.length.must_equal 1, 'did not send exactly one email'
  end

  it 'sends out email to recipient' do
    system(cmd)
    puts @smtp_server.received
    @smtp_server.received.first[:to].must_equal "<#{recipient}>", "recipient is not #{recipient}"
  end

end
