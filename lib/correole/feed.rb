class Feed

  def self.get
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


end
