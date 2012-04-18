require 'image_size'

usage       'images'
summary     'prepares images'
description 'Prepares images for uploads, i.e. strips them of metadata, compresses them and so on.'

required :s, :sites, 'sites'

module Nanoc::CLI::Commands
  class Images < ::Nanoc::CLI::CommandRunner
    def run
      sites_arg(options[:sites]).each do |site|
        img_dir = "content_#{site}/pigs"
        exts = "{" + %w{jpg png gif}.join(",") + "}"
        
        # resize all large images
        Dir["#{img_dir}/*.#{exts}"].select {|f| ImageSize.new(IO.read(f)).width > 400}.map do |img|
          small_img = img.gsub /^(.+)\.(\w+)$/, '\1_small.\2'

          next if File.exists? small_img and File.mtime(small_img) >= File.mtime(img)

          puts "resizing #{img}..."
          system "convert -resize '400' #{img} #{small_img}"
        end

        # strip exif
        system "exiftool -all= -overwrite_original #{img_dir}/*.#{exts}"
      end
    end
  end
end

runner Nanoc::CLI::Commands::Images
