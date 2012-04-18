usage       'last'
summary     'open last page'
description 'Opens last page in Emacs.'

module Nanoc::CLI::Commands
  class Last < ::Nanoc::CLI::CommandRunner
    def run
      page = daily_logs.last
      puts "editing: #{page}..."
      system "emacs-gui #{page}"
    end
  end
end

runner Nanoc::CLI::Commands::Last


