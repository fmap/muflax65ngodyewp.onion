# backup all important external data

namespace :backup do
  desc "backup links"
  task :links do
    system "./backup-links.sh"
  end

  desc "backup videos"
  task :videos do
    system "./backup-videos.rb"
  end
end

desc "backup everything"
task :backup => ['backup:links', 'backup:videos']
