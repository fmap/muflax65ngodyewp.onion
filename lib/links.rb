def local_link url
  if m = url.match(/^(?<site>\w+):(?<page>.+)$/)
    "#{site_url m[:site]}/#{m[:page]}"
  else
    raise "invalid format: #{self[:merged]}"
  end
end

def site_url site
  "http://#{site == "muflax" ? "" : "#{site}."}muflax.com"
end

def site_link site
  site = site.to_s
  
  url = site_url site
  title = @site.site_yaml["sites"][site]["title"]

  "#{url} - #{title}"
end

def topic_link topic, target
  url = local_link target

  "#{url} - #{topic}"
end

class Nanoc::Site
  def moved_pages
    moved = []
    sites = @moved_yaml["sites"]
    if sites.include? @name
      sites[@name].each do |m|
        moved << [m["from"], local_link(m["to"])]
      end
    end

    moved
  end
end
