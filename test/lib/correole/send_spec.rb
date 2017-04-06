require File.expand_path '../../../test_helper.rb', __FILE__

describe 'Send' do

  let(:subscriber1) { Subscriber.new(email: 'subscriber1@gmail.com') }
  let(:subscriber2) { Subscriber.new(email: 'subscriber2@gmail.com') }

  let(:title) { 'Ruslan writes code' }
  let(:item1_pub_date) { 'Fri, 17 Jun 2016 00:00:00 +0000' }
  let(:item1) {
    Item.new(title: "title1",
             description: "description1",
             link: "http://ruslanledesma.com/uri1_#{Time.now.to_i}",
             pub_date: Time.parse(item1_pub_date))
  }
  let(:item2) {
    Item.new(title: 'title2',
             description: 'description2',
             link: "http://ruslanledesma.com/uri2_#{Time.now.to_i}")
  }
  let(:item3_pub_date) { 'Thu, 26 May 2016 00:00:00 +0000' }
  let(:item3) {
    Item.new(title: 'title3',
             description: 'description3',
             link: "http://ruslanledesma.com/uri3_#{Time.now.to_i}",
             pub_date: Time.parse(item3_pub_date))
  }
  let(:item4_pub_date) { 'Thu, 26 May 2016 00:00:00 +0000' }
  let(:item4) {
    Item.new(title: 'title4',
             description: 'description4',
             link: "http://ruslanledesma.com/uri4_#{Time.now.to_i}",
             pub_date: Time.parse(item4_pub_date))
  }
  let(:item5_pub_date) { 'Sat, 23 Apr 2016 00:00:00 +0000' }
  let(:item5) {
    Item.new(title: 'title5',
             description: 'description5',
             link: "http://ruslanledesma.com/uri5_#{Time.now.to_i}",
             pub_date: Date.parse(item5_pub_date))  }
  let(:item6) {
    Item.new(title: 'title6',
             description: 'description6',
             link: "http://ruslanledesma.com/uri6_#{Time.now.to_i}") }
  let(:xml) {
    <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>#{title}</title>
    <description>Uebung macht den Meister.</description>
    <link>http://ruslanledesma.com/</link>
    <atom:link href="http://ruslanledesma.com/feed.xml" rel="self" type="application/rss+xml"/>
    <pubDate>Sun, 10 Jul 2016 00:18:32 +0000</pubDate>
    <lastBuildDate>Sun, 10 Jul 2016 00:18:32 +0000</lastBuildDate>
    <generator>Jekyll v3.1.6</generator>
      <item>
        <title>#{item1.title}</title>
        <description>#{item1.description}</description>
        <pubDate>#{item1_pub_date}</pubDate>
        <link>#{item1.link}</link>
        <guid isPermaLink="true">#{item1.link}</guid>
      </item>
      <item>
        <title>#{item2.title}</title>
        <description>#{item2.description}</description>
        <link>#{item2.link}</link>
        <guid isPermaLink="true">#{item2.link}</guid>
      </item>
      <item>
        <title>#{item3.title}</title>
        <description>#{item3.description}</description>
        <pubDate>#{item3_pub_date}</pubDate>
        <link>#{item3.link}</link>
        <guid isPermaLink="true">#{item3.link}</guid>
      </item>
      <item>
        <title>#{item4.title}</title>
        <description>#{item4.description}</description>
        <pubDate>#{item4_pub_date}</pubDate>
        <link>#{item4.link}</link>
        <guid isPermaLink="true">#{item4.link}</guid>
      </item>
      <item>
        <title>#{item5.title}</title>
        <description>#{item5.description}</description>
        <pubDate>#{item5_pub_date}</pubDate>
        <link>#{item5.link}</link>
        <guid isPermaLink="true">#{item5.link}</guid>
      </item>
      <item>
        <title>#{item6.title}</title>
        <description>#{item6.description}</description>
        <link>#{item6.link}</link>
        <guid isPermaLink="true">#{item6.link}</guid>
      </item>
  </channel>
</rss>
EOF
  }
  let(:split_feed) {
    {
      :title => title,
      :unsent_item => [ item1, item2 ],
      :sent_item => [ item3, item4, item5, item6 ]
    }
  }
  let(:html) {
    <<-EOF
<html>
  <body>
    <h1>#{title}</h1>
    <h2>Items</h2>
    <ul>

      <li>
        <i>#{item1.pub_date.to_date}</i>
        <h3>
          <a href="#{item1.link}">#{item1.title}</a>
        </h3>
        <p>#{item1.description}</p>
      </li>

      <li>
        <h3>
          <a href="#{item2.link}">#{item2.title}</a>
        </h3>
        <p>#{item2.description}</p>
      </li>

    </ul>

    <a href="http://newsletter.ruslanledesma.com/unsubscribe/?email=<%= recipient %>">Unsubscribe here.</a>
  </body>
</html>
EOF
  }
  let(:html_subscriber1) {
    <<-EOF
<html>
  <body>
    <h1>#{title}</h1>
    <h2>Items</h2>
    <ul>

      <li>
        <i>#{item1.pub_date.to_date}</i>
        <h3>
          <a href="#{item1.link}">#{item1.title}</a>
        </h3>
        <p>#{item1.description}</p>
      </li>

      <li>
        <h3>
          <a href="#{item2.link}">#{item2.title}</a>
        </h3>
        <p>#{item2.description}</p>
      </li>

    </ul>

    <a href="http://newsletter.ruslanledesma.com/unsubscribe/?email=#{subscriber1.email}">Unsubscribe here.</a>
  </body>
</html>
EOF
  }
  let(:plain) {
    <<-EOF
#{title}

Items

- #{item1.title}
  #{item1.pub_date.to_date}
  #{item1.link}

  #{item1.description}

- #{item2.title}
  #{item2.link}

  #{item2.description}

Unsubscribe here: http://newsletter.ruslanledesma.com/unsubscribe/?email=<%= recipient %>
EOF
  }
  let(:plain_subscriber1) {
    <<-EOF
#{title}

Items

- #{item1.title}
  #{item1.pub_date.to_date}
  #{item1.link}

  #{item1.description}

- #{item2.title}
  #{item2.link}

  #{item2.description}

Unsubscribe here: http://newsletter.ruslanledesma.com/unsubscribe/?email=#{subscriber1.email}
EOF
  }

  describe '.run!' do

    before do
      Mail.defaults { delivery_method :test }
      Mail::TestMailer.deliveries.clear
      Subscriber.destroy_all
      subscriber1.save
      subscriber2.save
      Item.destroy_all
      split_feed[:sent_item].each { |i| i.save }
    end

    it 'sends out the newsletter to all subscribers' do
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      Subscriber.find_each do |s|
        assert Mail::TestMailer.deliveries.any? { |m| m.to[0] == s.email }, "newsletter was not sent to subscriber #{s.email}"
      end
    end

    it 'sends out the newsletter only to subscribers' do
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      Subscriber.find_each do |s|
        Mail::TestMailer.deliveries.keep_if { |m| m.to[0] != s.email }
      end
      Mail::TestMailer.deliveries.must_equal [], 'newsletter was sent to unknown recipients'
    end

    it 'sends each mail only to one recipient' do
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      Mail::TestMailer.deliveries.each do |m|
        m.to.length.must_equal 1, 'newsletter was not sent to only one recipient'
      end
    end

    it 'remembers each unsent item' do
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      split_feed[:unsent_item].each do |i|
        Item.find_by_link(i.link).wont_be_nil "item #{i.link} was not saved"
      end
    end

    it 'does not send any email when you already sent all available items' do
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      Mail::TestMailer.deliveries.clear
      Net::HTTP.stub :get, xml do
        Send.run!
      end
      Mail::TestMailer.deliveries.each do |m|
        m.to.length.must_equal 0, 'newsletter was sent to some recipient'
      end
    end

    class SendOutExc < Send
      class << self
        attr_accessor :exception, :bad_recipient
      end

      def self.send_out(title, html, plain, recipient)
        if recipient == @bad_recipient
          @exception = true
          msg = '550-Requested action not taken: mailbox unavailable'
          raise Net::SMTPFatalError.new(msg)
        end
        return super.send_out(title, html, plain, recipient)
      end
    end

    it 'does not stop when there is an exception in send_out' do
      SendOutExc.exception = false
      SendOutExc.bad_recipient = subscriber1.email
      Net::HTTP.stub :get, xml do
        SendOutExc.run!
      end
      assert SendOutExc.exception, 'there was no exception'
      Mail::TestMailer.deliveries.each do |m|
        m.to.length.must_equal 1, 'newsletter was not sent to only one recipient'
      end
    end

  end

  describe '.template_bindings' do

    it 'returns template bindings' do
      b = Send.send(:template_bindings, split_feed)
      b.eval('title').must_equal split_feed[:title]
      b.eval('unsent_items').must_equal split_feed[:unsent_item]
      b.eval('sent_items').must_equal split_feed[:sent_item]
      b.eval('unsubscribe_uri').must_equal Configuration.unsubscribe_uri
    end

  end

  describe '.compose_html' do

    it 'composes html message from split feed' do
      Send.send(:compose_html, split_feed).must_equal html
    end

  end

  describe '.compose_plain' do

    it 'composes plain message from split feed' do
      Send.send(:compose_plain, split_feed).must_equal plain
    end

  end

  describe '.personalize' do

    it 'personalizes given html message for given recipient' do
      Send.send(:personalize, html, subscriber1.email).must_equal html_subscriber1
    end

    it 'personalizes given plain message for given recipient' do
      Send.send(:personalize, plain, subscriber1.email).must_equal plain_subscriber1
    end

  end

  describe '.send_out' do

    before do
      Mail.defaults { delivery_method :test }
      Mail::TestMailer.deliveries.clear
    end

    it 'sends out the message' do
      mail = Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      Mail::TestMailer.deliveries[0].must_equal mail
    end

    it 'applies title to the sender' do
      Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      mail = Mail::TestMailer.deliveries[0]
      /From: ([^\r\n]+)/.match(mail.to_s)[1].must_equal ERB.new(Configuration.from).result(binding)
    end

    it 'addresses email to given recipient' do
      Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      mail = Mail::TestMailer.deliveries[0]
      /To: ([^\r\n]+)/.match(mail.to_s)[1].must_equal subscriber1.email
    end

    it 'applies title and date to the subject' do
      date = nil # supress unused variable warning
      date = Date.today.strftime('%a, %d %b %Y')
      expected = ERB.new(Configuration.subject).result(binding)
      Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      mail = Mail::TestMailer.deliveries[0]
      /Subject: ([^\r\n]+)/.match(mail.to_s)[1].must_equal expected
    end

    it 'includes the html part' do
      Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      mail = Mail::TestMailer.deliveries[0]
      assert mail.to_s.index(html_subscriber1.gsub(/\n/, "\r\n")) != nil, 'mail does not include html part'
    end

    it 'includes the plain part' do
      Send.send(:send_out, title, html_subscriber1, plain_subscriber1, subscriber1.email)
      mail = Mail::TestMailer.deliveries[0]
      assert mail.to_s.index(plain_subscriber1.gsub(/\n/, "\r\n")) != nil, 'mail does not include plain part'
    end

  end

end
