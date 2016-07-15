class Send

  def self.run!
    qputs "Fetch feed from #{Configuration::FEED}."
    feed = Feed.get
    split_feed = Feed.split_items feed
    if split_feed[:unsent_item].empty?
      qputs 'There are no new items, exiting.'
      return
    end
    qputs "There are #{split_feed[:unsent_item].length} new items. The items are the following."
    split_feed[:unsent_item].each_with_index { |i, j| qputs "[#{j}] #{i.link}" }
    html = compose_html split_feed
    plain = compose_plain split_feed
    count = Subscriber.count
    Subscriber.find_each.with_index do |s, i|
      html_s = personalize html, s.email
      plain_s = personalize plain, s.email
      qputs "[#{i+1}/#{count}] Send newsletter to #{s.email}."
      begin
        send_out feed[:title], html_s, plain_s, s.email
      rescue => exc
        qputs "Could not send newsletter to #{s.email} for the following reason."
        qputs exc.message
      end
    end
    qputs 'Remember new items.'
    split_feed[:unsent_item].each { |i| i.save }
    qputs 'Done.'
  end

  private

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
    return ERB.new(template, nil, '-').result(bindings)
  end

  def self.compose_plain(split_feed)
    template = Configuration::PLAIN_TEMPLATE
    bindings = template_bindings(split_feed)
    return ERB.new(template, nil, '-').result(bindings)
  end

  def self.personalize(message, recipient)
    return ERB.new(message).result(binding)
  end

  def self.send_out(title, html, plain, recipient)
    date = nil # supress unused variable warning
    date = Date.today.strftime('%a, %d %b %Y')
    Mail.deliver do
      to      recipient
      from    ERB.new(Configuration::FROM).result(binding)
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
