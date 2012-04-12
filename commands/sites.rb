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

            puts "extending config..."

            @config[:output_dir] = "out/#{$site}"
            
            @config[:data_sources] = [{
                                        type: "filesystem_customizable",
                                        source_dir: ["content_#{$site}"],
                                        items_root: "/",
                                        layouts_root: "/",
                                        config: {},
                                      }]
            @config[:data_sources].map! { |ds| ds.symbolize_keys }

            ssh =
              if $site == "muflax"
                $site
              else
                "muflax-#{$site}"
              end
            
            @config[:deploy] = {
              default: {
                dst: "#{ssh}:/home/public",
                options: ['-gpPrtvz', '--delete'],
                kind: "rsync"
              }
            }

            @config[:watcher][:dirs_to_watch] << "content_#{$site}"
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
