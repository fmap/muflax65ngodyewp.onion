module Nanoc
  class Site
    def main_site?
      $site == "muflax"
    end

    def blog?
      !main_site? # everything is a blog except for the main site
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

    def url
      "http://#{main_site? ? "" : "#{$site}."}muflax.com"
    end

    
    def disqus_url item
      url + item.identifier
    end

    def title
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
  end
end
