require File.expand_path '../../test_helper.rb', __FILE__

describe 'Command `correole`' do

  let(:port) { 5987 }
  let(:timeout) { 10 }
  let(:root) { File.expand_path '../../../', __FILE__ }
  let(:cmd) {
    <<-EOF
PORT=#{port} \
bundle exec ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole
EOF
  }

  it "runs API" do
    spawn(cmd, [ :err, :out ] => '/dev/null')
    stop = Time.now.to_i + timeout
    while ! system("lsof -i TCP:#{port}", [ :err, :out ] => '/dev/null') && Time.now.to_i < stop
      sleep 0.0625
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

describe 'Submission of newsletter' do

  let(:recipient) { 'subscriber@localhost' }
  let(:timeout) { 10 }
  let(:http_port) { 9090 }
  let(:http_host) { 'localhost' }
  let(:smtp_port) { 9191 }
  let(:smtp_host) { 'localhost' }
  let(:feed_uri) { "http://#{http_host}:#{http_port}/feed.xml" }
  let(:root) { File.expand_path '../../../', __FILE__ }
  let(:cmd_send) {
    <<-EOF
RACK_ENV=test \
FEED=#{feed_uri} \
SMTP_HOST=#{smtp_host} \
SMTP_PORT=#{smtp_port} \
bundle exec ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole send #{Configuration.quiet ? '-q' : ''}
EOF
  }
  let(:cmd_test) {
    <<-EOF
RACK_ENV=test \
FEED=#{feed_uri} \
SMTP_HOST=#{smtp_host} \
SMTP_PORT=#{smtp_port} \
bundle exec ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole test #{Configuration.quiet ? '-q' : ''}
EOF
  }
  let(:cmd_purge) {
    <<-EOF
RACK_ENV=test \
FEED=#{feed_uri} \
SMTP_HOST=#{smtp_host} \
SMTP_PORT=#{smtp_port} \
bundle exec ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole purge #{Configuration.quiet ? '-q' : ''}
EOF
  }

  before do
    # Configure only one subscriber
    Subscriber.destroy_all
    s = Subscriber.new(email: recipient)
    s.save

    # Forget everything we have sent
    Item.destroy_all

    # Catch mail
    @smtp_server = SmtpServer.new(smtp_port, 'localhost', 1)
    @smtp_server.start

    # Go quiet
    if Configuration.quiet
      @curr_stdout = $stdout
      @curr_stderr = $stderr
      $stdout = StringIO.new
      $stderr = StringIO.new
      Thin::Logging.silent = true
    end

    # Provide feed
    FeedServer.set :port, http_port
    @http_server = Thread.new { FeedServer.run! }
    stop = Time.now.to_i + timeout
    while ! FeedServer.running? && Time.now.to_i < stop
      sleep 0.0625
    end
  end

  after do
    @smtp_server.stop
    @smtp_server.join

    FeedServer.quit!
    @http_server.join

    # Stop the silence
    if Configuration.quiet
      $stdout = @curr_stdout
      $stderr = @curr_stderr
    end
  end

  describe 'Command `correole send`' do

    it 'does not fail' do
      assert system(cmd_send), "command `#{cmd_send}` fails"
    end

    it 'sends out only one email' do
      system(cmd_send)
      @smtp_server.received.length.must_equal 1, 'did not send only one email'
    end

    it 'sends out email to recipient' do
      system(cmd_send)
      puts @smtp_server.received
      @smtp_server.received.first[:to].must_equal "<#{recipient}>", "recipient is not #{recipient}"
    end

    it 'remembers sent items and does not send any of them again' do
      system(cmd_send)
      @smtp_server.received.clear
      system(cmd_send)
      @smtp_server.received.length.must_equal 0, 'newsletter was sent to some recipient'
    end

  end

  describe 'Command `correole test`' do

    it 'does not fail' do
      assert system(cmd_test), "command `#{cmd_test}` fails"
    end

    it 'sends out only one email' do
      system(cmd_test)
      @smtp_server.received.length.must_equal 1, 'did not send only one email'
    end

    it 'sends out email to recipient' do
      email = Configuration.dry_run_email
      system(cmd_test)
      puts @smtp_server.received
      @smtp_server.received.first[:to].must_equal "<#{email}>", "recipient is not #{email}"
    end

    it 'does not remember sent items so that it sends them again' do
      system(cmd_test)
      @smtp_server.received.clear
      system(cmd_test)
      @smtp_server.received.length.must_equal 1, 'newsletter was not sent to only one recipient'
    end

  end

  describe 'Command `correole purge`' do

    it 'does not fail' do
      assert system(cmd_purge), "command `#{cmd_purge}` fails"
    end

    it 'remembers new items so that later `correole send` does not send any email' do
      system(cmd_purge)
      @smtp_server.received.clear
      system(cmd_send)
      @smtp_server.received.length.must_equal 0, 'newsletter was sent to some recipient'
    end

  end

end
