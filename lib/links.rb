# translates various link formats / demands into urls

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

class Category
  def link count=false
    desc = title
    desc += " (#{members.size})" if count
    
    "<a href='#{@item.identifier}'>#{desc}</a>"
  end
end
