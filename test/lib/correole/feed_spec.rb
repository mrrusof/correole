require File.expand_path '../../../test_helper.rb', __FILE__

describe 'Feed' do

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
  let(:feed) {
    {
      :title => title,
      :item =>
      [ item1, item2, item3, item4, item5, item6 ]
    }
  }
  let(:split_feed) {
    {
      :title => title,
      :unsent_item => [ item1, item2 ],
      :sent_item => [ item3, item4, item5, item6 ]
    }
  }
  let(:split_feed_all_sent) {
    {
      :title => title,
      :unsent_item => [],
      :sent_item => [ item1, item2, item3, item4, item5, item6 ]
    }
  }
  let(:split_feed_none_sent) {
    {
      :title => title,
      :unsent_item => [ item1, item2, item3, item4, item5, item6 ],
      :sent_item => []
    }
  }

  describe '.get' do

    it 'returns a hash' do
      Net::HTTP.stub :get, xml do
        assert Feed.get.is_a?(Hash), 'return value is not a hash'
      end
    end

    it 'projects the feed' do
      Net::HTTP.stub :get, xml do
        Feed.get.must_equal feed
      end
    end

  end

  describe '.split_items' do

    it 'splits list of items into sent and unsent' do
      Item.destroy_all
      split_feed[:sent_item].each { |i| i.save }
      actual = Feed.split_items feed
      actual[:unsent_item].sort.must_equal split_feed[:unsent_item].sort
    end

    it 'declares all items unsent when there are no sent items' do
      Item.destroy_all
      Feed.split_items(feed).must_equal split_feed_none_sent
    end

    it 'declares all items sent when all items have been sent' do
      Item.destroy_all
      feed[:item].each { |i| i.save }
      Feed.split_items(feed).must_equal split_feed_all_sent
    end

  end

end
