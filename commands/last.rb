usage       'last'
summary     'open last page'
description 'Opens last page in Emacs.'

module Nanoc::CLI::Commands
  class Last < ::Nanoc::CLI::CommandRunner
    def run
      site = load_site "daily"

      logs = site.items_by_date.select do |i|
        i.reps.any? {|r| r.name == :wordcount}
      end

      page = logs.last[:filename]
      puts "editing: #{page}..."
      system "emacs-gui #{page}"
    end
  end

  
end

runner Nanoc::CLI::Commands::Last


