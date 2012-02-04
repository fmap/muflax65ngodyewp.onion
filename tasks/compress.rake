# compress all text files in out/ to save on traffic

namespace :compress do
  desc "compress html (and related) files"
  task :html do
    system "./compress-html.sh"
  end

end

desc "compress everything"
task :compress => ['compress:html']
