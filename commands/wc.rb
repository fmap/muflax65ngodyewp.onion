usage       'wc'
summary     'word count of logs'
description 'Prints word count of log entries for Beeminder logging.'

module Nanoc::CLI::Commands
  class WordCount < ::Nanoc::CLI::CommandRunner
    def run
      daily_logs.each do |log|
        data = File.read(log)
        pieces = data.split(/^(-{5}|-{3})\s*$/)
        next if pieces.size < 4

        content = pieces[4..-1].join.strip
        words = content.scan(/( \[.+?\]\[.*?\][[:punct:]]* | <%=?.+?%> | \S+ )/x)
        
        puts "#{log} -> #{words.size}"
      end
    end
  end
end

runner Nanoc::CLI::Commands::WordCount
