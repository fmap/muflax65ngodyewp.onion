usage       'last'
summary     'open last page'
description 'Opens last page in Emacs.'

module Nanoc::CLI::Commands
  class Compress < ::Nanoc::CLI::CommandRunner
    def run
      page = Dir['content_daily/log/*.mkd'].map do |l|
        [l.match(/\/(\d+).mkd$/)[1].to_i, l]
      end.sort.last[1]
      puts "editing: #{page}..."
      system "emacs-gui #{page}"
    end
  end
end

runner Nanoc::CLI::Commands::Compress


