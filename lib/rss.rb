# build rss feed
def rss_feed
  require "rss/maker"
  version = "2.0"

  # find changelog
  log = @items.find{|i| i.identifier.match %r{/changelog/}}
  
  content = RSS::Maker.make(version) do |rss|
    rss.channel.title = "Lies and Wonderland"
    rss.channel.link = "http://muflax.com"
    rss.channel.author = "mail@muflax.com"
    rss.channel.description = "Lies and Wonderland"
    rss.items.do_sort = true # sort items by date

    # add changelog
    changes(log).each do |change|
      i = rss.items.new_item
      i.title = "muflax hath written unto you..."
      i.link = "http://muflax.com/changelog/"
      i.date = Time.parse(change[:date])
      i.description = change[:description]
    end

    # add all non-draft articles once
    articles = @site.printed_items.select{|i| i.article?}
    
    articles.each do |item|
      i = rss.items.new_item
      i.title = "#{item[:title]}"
      i.link = "http://muflax.com" + item.path
      i.date = item[:date].to_time
      i.description = "New Page: <a href='#{i.link}'>#{i.title}</a>"
    end

    # mod date is newest article / entry in log
    rss.channel.date = [articles.map{|i| i[:date].to_time}, log.mtime].flatten.max

  end

  content
end

# return changes based on changelog
def changes log
  require 'nokogiri'

  changes = []

  # parse log
  html_log = Nokogiri::HTML(log.compiled_content)
  html_log.css("ul#changelog").each do |ul|
    ul.css("li").each do |li|
      change = {}
      change[:description] = li.children.to_s.strip
      change[:date] = li.content[%r{\d{4}/\d{2}/\d{2}}]
      changes << change
    end
  end

  changes
end
