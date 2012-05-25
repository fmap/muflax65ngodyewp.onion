# Helper functions for epistemic states.

def techne_title status
  case status
  when :rough
    "needs work"
  when :wip
    "work in progress"
  when :done
    "finished"
  else
    status.to_s
  end
end

def episteme_title status
  case status
  when :broken
    "semi-believed"
  when :discredited
    "not believed"
  else
    status.to_s
  end
end

def episteme_cat status
  "<a class='episteme' href='/episteme/'>#{episteme_title status}</a>"
end

class Nanoc::Item
  def epistemic?
    !!self[:episteme]
  end

  def mindkiller?
    topics = %w{history}
    !!self[:mindkiller]
  end

  def merged?
    !!self[:merged]
  end

  def merged_link
    raise "no merged link for #{self.identifier}" unless self[:merged]

    if m = self[:merged].match(/^(?<site>\w+):(?<page>.+)$/)
      "http://#{m[:site] == "muflax" ? "" : "#{m[:site]}."}muflax.com/#{m[:page]}"
    else
      raise "invalid format: #{self[:merged]}"
    end
  end
end
