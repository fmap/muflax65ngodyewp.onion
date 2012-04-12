usage       'videos'
summary     'backup videos'
description 'Backups all videos in content files.'

run do
  system "./backup-videos.rb"
end
