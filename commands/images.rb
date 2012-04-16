usage       'images'
summary     'prepares images'
description 'Prepares images for uploads, i.e. strips them of metadata, compresses them and so on.'

module Nanoc::CLI::Commands
  class Images < ::Nanoc::CLI::CommandRunner
    def run
      img_dir = "content/pigs"

      # strip exif
      system "exiftool -all= -overwrite_original #{img_dir}/*.{jpg,png}"

      # compress png
      system "optipng #{img_dir}/*.png"
    end
  end
end

runner Nanoc::CLI::Commands::Images
