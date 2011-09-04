# Helper functions for site-building.

include Nanoc3::Helpers::Breadcrumbs
include Nanoc3::Helpers::Rendering

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

def category name
  render "category", :category => name
end

# only articles that actually get printed
def printed_items
  @items.select { |i| not i[:is_hidden] and not i.binary? }
end
