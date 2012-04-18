# Helper functions for epistemic states.

def techne status
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

def episteme status
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
  "[#{episteme status}][Epistemic State]{:.episteme}"
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
