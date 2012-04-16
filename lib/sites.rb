def main_site?
  $site == "muflax"
end

def blog?
  $site =~ /^(blog|daily)$/
end

def sites
  Dir['content_*'].map{|d| d.gsub(/^content_/, '')}
end

