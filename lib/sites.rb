def main_site?
  true
end

def blog?
  false
end

def sites
  Dir['content_*'].map{|d| d.gsub(/^content_/, '')}
end

