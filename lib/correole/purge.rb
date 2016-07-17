class Purge

  def self.run!
    qputs "Fetch feed from #{Configuration.feed}."
    feed = Feed.get
    unsent_items = Feed.split_items(feed)[:unsent_item]
    if unsent_items.empty?
      qputs 'There are no new items, exiting.'
      return
    end
    qputs "There are #{unsent_items.length} new items. The items are the following."
    unsent_items.each_with_index { |i, j| qputs "[#{j+1}] #{i.link}" }
    qputs 'Purge the new items by remembering them.'
    unsent_items.each { |i| i.save }
    qputs 'Done.'
  end

end
