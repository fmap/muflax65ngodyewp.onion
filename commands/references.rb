usage       'references'
summary     'updates references.mkd'
description 'Updates reference file with all internal links.'

required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class References < ::Nanoc::CLI::CommandRunner

    # collect links in site
    def extract_links site=nil
      current_site = load_site site

      shared = site.nil?
      
      page_links = ["<!-- (auto-generated) internal links for #{shared ? "shared content" : "site: #{site}"} -->"]
      
      current_site.printed_items.each do |i|
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

