# Helper functions for site-building.

include Nanoc3::Helpers::Breadcrumbs

class Nanoc3::Item
  def add_content content
    @raw_content += "\n\n#{content}"
  end
  
  def add_references refs
    add_content refs
  end

  def name
    identifier.split("/").last
  end
end

# print all items in a category, nicely formatted
def category name
  output = []
  cat_match = %r{^/#{name}/}
  
  # find category index
  cat_index = printed_items.find{|i| i.path.match(cat_match) and i[:is_category]}

  # header
  output << "# [#{cat_index[:title]}]"

  # find items in category
  items = printed_items.select do |i|
    ( not i[:is_category] and
      i.path.match cat_match
      )
  end

  # items in nice list
  items.sort_by{|i| i[:title]}.each do |i|
    output << "- [#{i[:title]}]"
  end

  # output
  output.map{|i| "#{i}\n"}.join
end

# only articles that actually get printed
def printed_items
  @items.select { |i| not i[:is_hidden] and not i.binary? }
end
    
#automatic links for all pages, used by reference file
def page_references
  output = []
  printed_items.each do |i|
    output << "[#{i[:title]}]: #{i.identifier}"

    unless i[:alt_titles].nil?
      i[:alt_titles].each do |title|
        output << "[#{title}]: #{i.identifier}"
      end
    end
  end

  # output
  output.map{|i| "#{i}\n"}.join
end
