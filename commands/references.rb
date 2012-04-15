usage       'references'
summary     'updates references.mkd'
description 'Updates reference file with all internal links.'

required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class References < ::Nanoc::CLI::CommandRunner

    # load data from site
    def load_site(site=nil)
      self.require_site
      @current_site = self.site

      # load site-specific config
      @current_site.extended_build_config('.', site) unless site.nil?
      
      # load site data (including plugins)
      @current_site.load

      # find relevant items
      @current_site.find_printed_items
    end

    # collect links in site
    def extract_links site=nil
      shared = site.nil?
      
      page_links = ["<!-- (auto-generated) internal links for #{shared ? "shared content" : "site: #{site}"} -->"]
      
      @current_site.printed_items.each do |i|
        # don't include shared content with sites
        unless shared
          next if i.shared?
        end
        
        page_links << "[#{i[:title]}]: #{i.identifier}"
      
        unless i[:alt_titles].nil?
          i[:alt_titles].each do |title|
            page_links << "[#{title}]: #{i.identifier}"
          end
        end
      end

      page_links
    end
    
    def run
      ([nil] + sites_arg(options[:sites])).each do |site|
        shared = site.nil?
        
        # load site
        if shared
          puts "loading: shared content"
        else
          puts "loading: #{site}"
        end
        
        load_site site

        page_links = extract_links site
        puts "#links: #{page_links.size}"

        # save reference file
        ref_file = "content/references/site_#{shared ? "shared" : "#{site}"}.mkd"
        puts "saving to: #{ref_file}"
        File.open(ref_file, "w").write(page_links.join("\n"))
      end
    end
  end
end

runner Nanoc::CLI::Commands::References

