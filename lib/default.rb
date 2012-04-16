# Helper functions for site-building.

include Nanoc::Helpers::Rendering

class Nanoc::Item
  def add_content content
    @raw_content += "\n\n#{content}"
  end
  
  def add_references refs
    add_content refs
  end

  def name
    identifier.split("/").last
  end

  # shared content or not?
  def shared?
    self[:filename].start_with? "content/"
  end
  
  def draft?
    self[:techne] == :wip
  end

  def cognitive?
    !self[:non_cognitive]
  end

  def article?
    not self[:is_category] and not draft? and cognitive?
  end

  def is_category? category
    !!path.match(%r{^/#{category}/})
  end
end

class Nanoc::Site
  # only articles that actually get printed
  attr_reader :printed_items

  def find_printed_items
    @printed_items = @items.select { |i| not i[:is_hidden] and not i.binary? }
  end

  def slug_items
    @printed_items.select {|i| not i[:slug].nil?}
  end
end

def category name
  render "category", :category => name
end

def route_unchanged
  item.identifier.chop + '.' + item[:extension]
end

def route_with_new_extension ext
  item.identifier.chop + '.' + ext
end

def google_search
  <<EOF
<div align="center"><form method="get" action="http://www.google.com/search">
  <input type="text" name="q" maxlength="255" />
  <input type="submit" value="Google Search" />
  <input type="hidden" name="domains" value="muflax.com" />
  <input style="visibility:hidden" type="radio" name="sitesearch" value="muflax.com" checked="checked" />
</form></div>
EOF
end

