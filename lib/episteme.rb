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
  when :mindkiller
    "mind-killing"
  else
    status.to_s
  end
end

def episteme_cat status
  "[#{episteme status}][Epistemic State]{:.episteme}"
end
