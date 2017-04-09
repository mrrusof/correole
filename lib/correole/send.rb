class Send

  def self.run!
    qputs "Fetch feed from #{Configuration.feed}."
    feed = Feed.get
    split_feed = Feed.split_items feed
    if split_feed[:unsent_item].empty?
      qputs 'There are no new items, exiting.'
      return
    end
    qputs "There are #{split_feed[:unsent_item].length} new items. The items are the following."
    split_feed[:unsent_item].each_with_index { |i, j| qputs "[#{j+1}] #{i.link}" }
    html = compose_html split_feed
    plain = compose_plain split_feed
    rr = recipients
    rr.each_with_index do |r, i|
      html_r = personalize html, r.email
      plain_r = personalize plain, r.email
      qputs "[#{i+1}/#{rr.size}] Send newsletter to #{r.email}."
      begin
        send_out feed[:title], html_r, plain_r, r.email
      rescue => exc
        qputs "Could not send newsletter to #{r.email} for the following reason."
        qputs exc.message
      end
    end
    if not Configuration.dry_run
      qputs 'Remember new items.'
      split_feed[:unsent_item].each { |i| i.save }
    end
    qputs 'Done.'
  end

  private

  def self.recipients
    if Configuration.dry_run
      s = Subscriber.new(email: Configuration.dry_run_email)
      return [s].each
    end
    return Subscriber.find_each
  end

  def self.template_bindings(split_feed)
    title = split_feed[:title]
    title = '' if !title.is_a?(String)
    unsent_items = split_feed[:unsent_item]
    unsent_items = [] if !unsent_items.is_a?(Array)
    sent_items = split_feed[:sent_item]
    sent_items = [] if !unsent_items.is_a?(Array)
    unsubscribe_uri = nil # supress unused variable warning
    unsubscribe_uri = Configuration.unsubscribe_uri
    return binding
  end

  def self.compose_html(split_feed)
    template = Configuration.html_template
    bindings = template_bindings(split_feed)
    return ERB.new(template, nil, '-').result(bindings)
  end

  def self.compose_plain(split_feed)
    template = Configuration.plain_template
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
      from    ERB.new(Configuration.from).result(binding)
      subject ERB.new(Configuration.subject).result(binding)

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
