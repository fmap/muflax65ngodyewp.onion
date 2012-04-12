usage       'links'
summary     'backup links'
description 'Backups all external links in content files.'

run do
  system "./backup-links.sh"
end
