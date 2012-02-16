require 'org-ruby'

class OrgFilter < Nanoc::Filter
  identifier :org
  
  def run(content, params={})
    Orgmode::Parser.new(content).to_html
  end
end
