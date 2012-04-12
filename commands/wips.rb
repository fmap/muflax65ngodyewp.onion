usage       'wips'
summary     'find all :wip articles'
description 'Finds all drafts, i.e. articles marked as :wip.'

run do |opts, args, cmd|
  system "grep -l ':wip' content*/**/*.mkd"
end
