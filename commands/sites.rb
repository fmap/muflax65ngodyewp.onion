# support for site-specific configs

# add option to all nanoc commands
Nanoc::CLI.root_command.modify do
  required :s, :site, "custom site" do |site, _|
    puts "set site: #{site}, adding config..."

    # make site globally accessibly
    $site = site
    
    module ::Nanoc
      class Site
        alias old_build_config build_config
        
        def build_config(dir_or_config_hash)
          # build default
          old_build_config(dir_or_config_hash)

          puts "extend config..."

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

# add list of all sites so that this file does something useful
usage       'sites'
summary     'prints all available sites'
description 'Prints all sites that can be used via -s SITE.'

module Nanoc::CLI::Commands
  class Sites < ::Nanoc::CLI::CommandRunner
    def run
      self.require_site
      puts "sites: #{Dir['content_*'].map{|d| d.gsub(/^content_/, '')}.join ', '}"
    end
  end
end

runner Nanoc::CLI::Commands::Sites
