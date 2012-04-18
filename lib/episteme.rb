# Helper functions for epistemic states.

def techne_title status
  case status
  when :rough
    "needs revisiting"
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
end
