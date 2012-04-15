usage       'dups'
summary     'find all duplicate links'
description 'Finds all duplicate links in the reference files.'

run do |opts, args, cmd|
  references = []
  
  Dir["content/references/*.mkd"].each do |ref|
    File.open(ref).each_line do |l|
      if m = l.match(/^ \*? \[ (?<link>.+?) \] : /x)
        references << {
          link: m[:link],
          full_link: l.strip,
          file: ref,
        }
      end
    end
  end

  last_ref = nil
  references.sort_by{|x| x[:link]}.each do |ref|
    if not last_ref.nil? and ref[:link] == last_ref[:link]
      puts "Duplicate link '#{ref[:link]}' in '#{ref[:file]}' <-> '#{last_ref[:file]}'!"
    end

    last_ref = ref
  end
     
end
