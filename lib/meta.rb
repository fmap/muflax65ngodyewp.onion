# meta tags for text sections

def meta &block
  annotate block do |c|
    div_wrap :meta, c
  end
end

def div_wrap tag, text
  "<div class='#{tag}' markdown='1'>#{text}</div>"
end

def skip &block
  annotate block do |c|
    c unless @item_rep.name == :wordcount
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
