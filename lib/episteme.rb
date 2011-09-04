# Helper functions for epistemic states.

def techne status
  case status
  when :rough
    "needs revisiting"
  when :incomplete
    "work in progress"
  when :done
    "finished"
  else
    status.to_s
  end
end

def episteme_cat status
  s = case status
      when :broken
        "partly believed"
      when :discredited
        "not believed"
      else
        status.to_s
      end
  "[#{s}][Epistemic State]{:.episteme}"
end
