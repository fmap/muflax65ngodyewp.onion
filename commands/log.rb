usage       'log'
summary     'create new log entry'
description 'Opens new log entry in Emacs.'

module Nanoc::CLI::Commands
  class CreateLog < ::Nanoc::CLI::CommandRunner
    def run
      site = load_site "daily"
      
      logs = site.items_by_date.select do |i|
        i.reps.any? {|r| r.name == :wordcount}
      end

      page = "content_daily" + logs.last.identifier.gsub(/(\d+)/){|s| s.to_i + 1}.chop + ".mkd"
      puts "editing: #{page}..."
      system "emacs-gui #{page}"
    end
  end
end

runner Nanoc::CLI::Commands::CreateLog


