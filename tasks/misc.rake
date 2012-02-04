# some misc helper functions

desc "find all :wip articles"
task :wips do
  system "grep -l ':wip' content/**/*.mkd"
end
