# support for site-specific configs

# built-in cmds than need a site option
site_cmds = [
             '(auto)?compile',
             'create_\w+',
             'debug',
             'deploy',
             'prune',
             'update',
             'view',
             'watch',
            ]

# site-specific config
module ::Nanoc
  class Site
    attr_accessor :name
    
    def extended_build_config(dir_or_config_hash, site)
      puts "load extended config..."

      @name = site
      @site_yaml = YAML.load(File.open("sites.yaml"))
      
      @config[:output_dir] = "out/#{site}"

      @config[:data_sources] = [{
                                  type: "filesystem_customizable",
                                  source_dir: ["content_#{site}"],
                                  items_root: "/",
                                  layouts_root: "/",
                                  config: {},
                                }]
      @config[:data_sources].map! { |ds| ds.symbolize_keys }

      ssh =
        if site == "muflax"
          site
        else
          "muflax-#{site}"
        end
      
      @config[:deploy] = {
        default: {
          dst: "#{ssh}:/home/public",
          options: ['-gpPrtvz', '--delete'],
          kind: "rsync"
        }
      }

      @config[:watcher][:dirs_to_watch] << "content_#{site}"

      @config[:base_url] = self.url
    end

    def main_site?
      @name == "muflax"
    end

    def blog?
      !main_site? # everything is a blog except for the main site
    end

    def [](attr)
      @site_yaml["sites"][@name][attr]
    end
    
    def disqus_site
      # TODO merge them all?
      # site -> disqus shortname
      self["disqus_site"]
    end

    def url
      "http://#{main_site? ? "" : "#{@name}."}muflax.com"
    end
    
    def disqus_url item
      url + item.identifier
    end

    def title
      self["title"]
    end
  end
end

# add option to all nanoc commands that operate on sites
Nanoc::CLI.root_command.commands.select do |cmd|
  cmd.name =~ /^(#{site_cmds.join("|")})/
end.each do |cmd|
  cmd.modify do
    required :s, :site, "custom site" do |site, _|
      puts "set site: #{site}"

      # make site globally accessibly
      $site = site

      module ::Nanoc
        class Site
          alias old_build_config build_config
          
          def build_config(dir_or_config_hash)
            # build default
            old_build_config(dir_or_config_hash)
            # build extended config
            extended_build_config(dir_or_config_hash, $site)
          end
        end
      end
    end
  end
end 

# helper function
module Nanoc::CLI
  class CommandRunner
    def all_sites
      Dir['content_*'].map{|d| d.gsub(/^content_/, '')}.sort
    end

    # lots of commands use -s now, so simplify its use
    def sites_arg sites
      sites.nil? ? all_sites : sites.split(",")
    end

    # load data from site
    def load_site site=nil
      self.require_site
      current_site = self.site

      # load site-specific config
      current_site.extended_build_config('.', site) unless site.nil?
      
      # load site data (including plugins)
      current_site.load

      current_site
    end

    def daily_logs
      dir = "content_daily/log"
      pattern = /\/(\d+).mkd$/
      
      Dir["#{dir}/*.mkd"].select{|l| l.match(pattern)}.sort_by do |l|
        l.match(pattern)[1].to_i
      end
    end
  end
end

# show list of all sites so that this file does something useful
usage       'sites'
summary     'prints all available sites'
description 'Prints all sites that can be used via -s SITE.'

module Nanoc::CLI::Commands
  class Sites < ::Nanoc::CLI::CommandRunner
    def run
      puts "sites: #{all_sites.join ', '}"
    end
  end
end

runner Nanoc::CLI::Commands::Sites
