class Send

  def self.run!
    split_feed = split_items feed
    html = compose_html split_feed
    plain = compose_plain split_feed
    Subscriber.find_each do |s|
      html_s = personalize html, s.email
      plain_s = personalize plain, s.email
      send_out feed[:title], html_s, plain_s, s.email
    end
    split_feed[:unsent_item].each { |i| i.save }
  end

  private

  def self.feed
    uri = URI Configuration::FEED
    xml = Net::HTTP.get uri
    hash = Hash.from_xml xml
    return {
      :title => hash['rss']['channel']['title'],
      :item => hash['rss']['channel']['item'].map { |i|
        pub_date = nil
        pub_date = Time.parse(i['pubDate']) if i.has_key? 'pubDate'
        Item.new(title: i['title'],
                 description: i['description'],
                 link: i['link'],
                 pub_date: pub_date)
      }
    }
  end

  def self.split_items(feed)
    split_feed = {
      :title => feed[:title],
      :unsent_item => [],
      :sent_item => []
    }
    feed[:item].each do |i|
      if Item.where(:link => i.link).any?
        split_feed[:sent_item] << i
      else
        split_feed[:unsent_item] << i
      end
    end
    return split_feed
  end

  def self.template_bindings(split_feed)
    title = split_feed[:title]
    unsent_items = split_feed[:unsent_item]
    sent_items = split_feed[:sent_item]
    unsubscribe_uri = nil # supress unused variable warning
    unsubscribe_uri = "#{Configuration::BASE_URI}/subscribers/<%= recipient %>"
    title = '' if !title.is_a?(String)
    unsent_items = [] if !unsent_items.is_a?(Array)
    sent_items = [] if !unsent_items.is_a?(Array)
    return binding
  end

  def self.compose_html(split_feed)
    template = Configuration::HTML_TEMPLATE
    bindings = template_bindings(split_feed)
    return ERB.new(template).result(bindings)
  end

  def self.compose_plain(split_feed)
    template = Configuration::PLAIN_TEMPLATE
    bindings = template_bindings(split_feed)
    return ERB.new(template).result(bindings)
  end

  def self.personalize(message, recipient)
    return ERB.new(message).result(binding)
  end

  def self.send_out(title, html, plain, recipient)
    date = nil # supress unused variable warning
    date = Date.today.strftime('%a, %d %b %Y')
    Mail.deliver do
      to      recipient
      from    Configuration::FROM
      subject ERB.new(Configuration::SUBJECT).result(binding)

      text_part do
        body plain
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body html
      end
    end
  end

end
