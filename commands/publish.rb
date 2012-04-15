# add list of all sites so that this file does something useful
usage       'publish'
summary     'publish site(s)'
description 'Publishes site(s) to all online targets.'

flag :p, :'pretend', 'pretend to publish'
required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class Publish < ::Nanoc::CLI::CommandRunner
    def run
      m = method(options[:pretend] ? :puts : :system)
      
      # push changes to github
      m.call "git push origin"

      # regenerate site links
      m.call "nanoc references"

      sites_arg(options[:sites]).each do |site|
        puts "publishing site: #{site}"
        
        # clean unneeded files
        m.call "nanoc prune -s #{site} --yes"

        # compile site to ensure a usable state
        m.call "nanoc compile -s #{site}"

        # compress files
        m.call "nanoc compress -s #{site}"

        # deploy files
        m.call "nanoc deploy -t default -s #{site}"
      end
    end
  end
end

runner Nanoc::CLI::Commands::Publish
