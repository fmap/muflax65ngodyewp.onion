# make all changes public

namespace :publish do
  desc "push changes to github"
  task :push do
    system "git push origin"
  end

  desc "compile site"
  task :compile do
    system "nanoc compile"
  end

  desc "push all files to website"
  task :deploy => [:compile, "deploy:rsync"] do
  end
end

desc "publish complete site"
task :publish => ['publish:push', 'compress', 'publish:deploy']
