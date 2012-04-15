usage       'compress'
summary     'compresses site(s)'
description 'Compresses all web files in given site(s).'

required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class Compress < ::Nanoc::CLI::CommandRunner
    def run
      sites_arg(options[:sites]).each do |site|
        system "./compress-html.sh #{site}"
      end
    end
  end
end

runner Nanoc::CLI::Commands::Compress
