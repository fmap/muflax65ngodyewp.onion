usage       'backup'
summary     'backup external data'
description 'Backups external data.'

run do |_, _, cmd|
  # backup everything
  %w(links videos).each do |s|
    cmd.command_named(s).run([])
  end
end
