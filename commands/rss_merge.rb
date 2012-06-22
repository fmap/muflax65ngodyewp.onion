usage       'rss-merge'
summary     'merge RSS feeds'
description 'Merges individual RSS feeds into one combined feed.'

module Nanoc::CLI::Commands
  class RSSMerge < ::Nanoc::CLI::CommandRunner
    def run
      require "rss"
      version = "2.0"

      date = Time.new 0
      items = []

      # read individual feeds and include them
      all_sites.each do |name|
        site = load_site name
        puts "including #{name}..."

        feed = RSS::Parser.parse(File.open("#{site.config[:output_dir]}/rss.xml"))
        date = [feed.channel.date, date].max
        items.concat feed.items
      end

      # build merged feed
      merged_feed = RSS::Maker.make(version) do |rss|
        rss.channel.title = "muflax"
        rss.channel.link = "http://muflax.com"
        rss.channel.author = "mail@muflax.com"
        rss.channel.description = "read ALL the muflax!"
      end
      merged_feed.items.concat items.sort_by(&:date).reverse.take(10)

      # write it
      File.open("out/muflax/rss-merged.xml", "w") do |f|
        f.write merged_feed
      end

      system "nanoc compress -s muflax"
    end
  end
end

runner Nanoc::CLI::Commands::RSSMerge
