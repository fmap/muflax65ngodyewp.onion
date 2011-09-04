# Helper functions for site-building.

include Nanoc3::Helpers::Breadcrumbs
include Nanoc3::Helpers::Rendering

class Nanoc3::Item
  def add_content content
    @raw_content += "\n\n#{content}"
  end
  
  def add_references refs
    add_content refs
  end

  def name
    identifier.split("/").last
  end
end

def category name
  render "category", :category => name
end

def techne status
  case status
  when :rough
    "needs revisiting"
  when :incomplete
    "work in progress"
  when :done
    "finished"
  else
    status.to_s
  end
end

def episteme_cat status
  s = case status
      when :broken
        "partly believed"
      when :discredited
        "not believed"
      else
        status.to_s
      end
  "[#{s}][Epistemic State]{:.episteme}"
end

# only articles that actually get printed
def printed_items
  @items.select { |i| not i[:is_hidden] and not i.binary? }
end

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
    rss.channel.date = log.mtime
    rss.items.do_sort = true # sort items by date

    changes(log).each do |change|
      i = rss.items.new_item
      i.title = "muflax hath written unto you..."
      i.link = "http://muflax.com/changelog/"
      i.date = Time.parse(change[:date])
      i.description = change[:description]
    end
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
