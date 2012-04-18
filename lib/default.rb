# Helper functions for site-building.

include Nanoc::Helpers::Rendering
include Nanoc::Helpers::XMLSitemap

class Nanoc::Item
  attr_accessor :category
  
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

  def category_slug
    if m = self.identifier.match(%r{^\/(?<cat>.+?)/})
      m[:cat]
    else
      ""
    end
  end
end

class Category
  attr_reader :item, :slug

  def initialize item, members=[]
    @item = item
    @slug = @item.category_slug
    @members = members

    @members.each {|i| i.category = self}
  end

  def includes? item
    !!item.identifier.match(%r{^/#{@slug}/})
  end

  def members drafts=false
    if drafts
      @members
    else
      @members.reject{|i| i.draft?}
    end
  end

  def title
    @item[:title]
  end

  def link count=false
    desc = title
    desc += " (#{@members.size})" if count
    
    "<a href='#{@item.identifier}'>#{desc}</a>"
  end
end

class Nanoc::Site
  # items
  attr_reader :printed_items # all items that end up on the site
  
  # slugs for wordpress links
  attr_reader :slug_items
  
  def initialize_items
    find_printed_items
    find_slug_items
    find_categories
  end

  def category name
    categories.find{|c| c.slug == name.to_s}
  end
  
  def find_printed_items
    @printed_items = @items.select { |i| not i[:is_hidden] and not i.binary? }
  end

  def find_slug_items
    @slug_items = @printed_items.select {|i| not i[:slug].nil?}
  end

  def items_by_date category=nil
    (category.nil? ? @printed_items : category.members).
      select{|i| i.article? and not i.draft?}. # exclude drafts etc.
      reject{|i| i[:date].nil?}.sort_by {|i| i[:date]} # sort by date
  end

  def find_categories
    # find categories
    cats = @printed_items.select {|i| i[:is_category]}.map do |c|
      members = @printed_items.select{|i| not i[:is_category] and i.category_slug == c.category_slug}
      Category.new(c, members)
    end

    # remove categories with no shown items
    cats = cats.map do |c|
      not_empty = @printed_items.any? do |i|
        c.includes? i and i.article? and not i.draft?
      end
      { cat: c, not_empty: not_empty}
    end

    # sort by title
    @categories = cats.sort_by {|c| c[:cat].title}
  end

  def categories all=true
    @categories.select{|c| c[:not_empty] or all}.map{|c| c[:cat]}
  end
end

def category name_or_cat
  name = if name_or_cat.is_a? Category
           name_or_cat.slug
         else
           name_or_cat.to_s
         end
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
<div align="center" class="search">
  <form method="get" action="http://www.google.com/search">
    <input type="text" name="q" maxlength="255" />
    <input type="submit" value="Search" />
    <input type="hidden" name="domains" value="muflax.com" />
    <input style="visibility:hidden" type="radio" name="sitesearch" value="muflax.com" checked="checked" />
  </form>
</div>
EOF
end

