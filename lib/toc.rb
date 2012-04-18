# table of contents generation

# add toc to current @item
class Nanoc::Item
  def toc
    require 'nokogiri'

    compiled_content = self.rep_named(:default).instance_eval { @content[:pre] }
    doc = Nokogiri::HTML(compiled_content)

    max_levels = 3

    # begin toc
    res = '<h2>Content</h2>'

    # iterate through the body, find headers and build toc as we go along
    level = 0
    doc.css("body").children.each do |node|
      if m = node.name.match(/^h(\d)$/)
        hlevel = m[1].to_i
        
        # nest lists
        diff = hlevel - level
        if diff > 0
          res << '<ol>' * diff
        elsif diff < 0
          res << "</ol>" * diff.abs
        end
        level = hlevel

        res << '<li>'
        res << '<a class="toc" href="' + '#' + node[:id] + '">' + node.text + '</a>'
        res << '</li>'
      end
    end

    # end toc
    res << '</ol>'
    res 
  end
end
