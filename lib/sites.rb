def main_site?
  $site == "muflax"
end

def blog?
  $site =~ /^(blog|daily)$/
end

def sites
  Dir['content_*'].map{|d| d.gsub(/^content_/, '')}
end

def disqus_site
  # TODO merge them all?
  # site -> disqus shortname
  case $site
  when "muflax"
    "muflax"
  when "sutra"
    "muflaxsutra"
  when "daily"
    "dailymuflax"
  when "blog"
    "muflaxblog"
  else # put 'em on the main site
    "muflax"
  end
end

def disqus_url item
  "http://#{main_site? ? "" : "#{$site}."}muflax.com#{item.identifier}"
end

def site_title
  case $site
  when "muflax"
    "lies and wonderland"
  when "sutra"
    "Blogchen"
  when "daily"
    "muflax becomes a saint"
  when "blog"
    "muflax' mindstream"
  else # placeholder
    "muflaxia"
  end
end
