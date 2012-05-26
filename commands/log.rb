usage       'log'
summary     'create new log entry'
description 'Opens new log entry in Emacs.'

module Nanoc::CLI::Commands
  class CreateLog < ::Nanoc::CLI::CommandRunner
    def run
      page = daily_logs.last.gsub(/(\d+)/) {|s| s.to_i + 1}
      puts "editing: #{page}..."
      system "emacs-gui #{page}"
    end
  end
end

runner Nanoc::CLI::Commands::CreateLog


