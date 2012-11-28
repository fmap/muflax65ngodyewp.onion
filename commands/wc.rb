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

        total = total_practice = 0
        logs.each do |log|
          practice  = words_in_content log, :wordcount
          all_words = words_in_content log, :default

          total          += all_words
          total_practice += practice
          
          puts "#{log.identifier} -> #{practice} / #{all_words}"
        end
        puts "total: #{total_practice} / #{total}"
      end
    end

    def words_in_content log, rep
      content  = log.rep_named(rep).compiled_content
      stripped = strip content.dup.force_encoding("utf-8")
      words    = stripped.scan(/( \S+ )/x)
      words.size
    end
    
    def strip content
      Sanitize.clean(content,
                     :remove_contents => %w{blockquote})
    end
  end
end

runner Nanoc::CLI::Commands::WordCount
