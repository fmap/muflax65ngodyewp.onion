# add list of all sites so that this file does something useful
usage       'publish'
summary     'publish site(s)'
description 'Publishes site(s) to all online targets.'

flag :p, :'pretend', 'pretend to publish'
required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class Publish < ::Nanoc::CLI::CommandRunner
    def run
      def cmd command
        m = method(options[:pretend] ? :puts : :system)
        m.call(command) or raise "command failed: '#{command}'"
      end
      
      # push changes to github
      cmd "git push origin"

      # regenerate site links
      cmd "nanoc references"

      # prepare images
      cmd "nanoc images"

      sites_arg(options[:sites]).each do |site|
        puts "publishing site: #{site}"
        
        # clean unneeded files
        cmd "nanoc prune -s #{site} --yes"

        # compile site to ensure a usable state
        cmd "nanoc compile -s #{site}"

        # compress files
        cmd "nanoc compress -s #{site}"

        # deploy files
        cmd "nanoc deploy -t default -s #{site}"
      end
    end
  end
end

runner Nanoc::CLI::Commands::Publish
