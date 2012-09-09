# meta tags for text sections

def meta &block
  annotate block do |c|
    div_wrap :meta, c
  end
end

# wrap in div tags
def div_wrap tag, text
  "<div class='#{tag}' markdown='1'>#{text}</div>"
end

# don't parse this when counting words
def skip &block
  annotate block do |c|
    c unless @item_rep.name == :wordcount
  end
end

# replace end-of-line with "  " used by markdown
def poem &block
  annotate block do |c|
    c.split("\n").join("  \n")
  end
end

def annotate content, &filter
  # get erbout so far
  erbout = eval('_erbout', content.binding)
  erbout_length = erbout.length

  # execute content block
  content.call

  # remove raw content
  raw = erbout[erbout_length..-1]
  erbout[erbout_length..-1] = ''

  # filter content, if possible
  filtered = block_given? ? filter.call(raw) : raw

  # print filtered content
  erbout << filtered unless filtered.nil?
end
