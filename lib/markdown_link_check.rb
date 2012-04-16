class MarkdownLinkCheck < Nanoc::Filter
  identifier :markdown_link_check
  
  def run(content, params={})
    content.each_line do |line|
      if line =~ /\[.+?\]\[.*?\]/
        puts "#{@item.identifier} -> #{line}" 
        raise "Unresolved link!"
      end
    end
  end
end


