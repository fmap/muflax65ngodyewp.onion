# build rss feed
def rss_feed
  require "rss/maker"
  version = "2.0"

  # find changelog
  log = @items.find{|i| i.identifier.match %r{/changelog/}}
  
  content = RSS::Maker.make(version) do |rss|
    rss.channel.title = @site.title
    rss.channel.link = @site.url
    rss.channel.author = "mail@muflax.com"
    rss.channel.description = @site.title
    rss.items.do_sort = true # sort items by date

    # add changelog, if available
    unless log.nil?
      changes(log).each do |change|
        i = rss.items.new_item
        i.title = "muflax hath written unto you..."
        i.link = "#{@site.url}/changelog/"
        i.date = Time.parse(change[:date])
        i.description = change[:description]
      end
    end

    # add all non-draft articles
    @site.items_by_date.last(5).each do |item|
      i = rss.items.new_item
      i.title = "#{item[:title]}"
      i.link = "#{@site.url}" + item.path
      i.date = item[:date].to_time
      i.description = tidy item.compiled_content
    end

    # mod date is newest article / entry in log
    last_article = @site.items_by_date.last[:date].to_time
    rss.channel.date = log.nil? ? last_article : [last_article, log.mtime].max
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
