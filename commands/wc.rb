usage       'wc'
summary     'word count of logs'
description 'Prints word count of log entries for Beeminder logging.'

require "sanitize"

module Nanoc::CLI::Commands
  class WordCount < ::Nanoc::CLI::CommandRunner
    def run
      sites = %w{daily}

      sites.each do |name|
        site = load_site name
        puts "compiling site (sorry)..."
        site.compile

        logs = site.items_by_date.select do |i|
          i.reps.any? {|r| r.name == :wordcount}
        end

        logs.each do |log|
          content = log.rep_named(:wordcount).compiled_content
          stripped = strip content.dup.force_encoding("utf-8")
          words = stripped.scan(/( \S+ )/x)
          puts "#{log.identifier} -> #{words.size}"
        end
      end
    end

    def strip content
      Sanitize.clean(content,
                     :remove_contents => %w{blockquote})
    end
  end
end

runner Nanoc::CLI::Commands::WordCount
