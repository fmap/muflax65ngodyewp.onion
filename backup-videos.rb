#!/usr/bin/env ruby
# coding: utf-8
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

hosts = [
         "youtube.com/v",
         "youtube.com/watch",
         "vimeo.com",
         "dailymotion.com",
         "video.google.com",
        ]

urls = `grep -horP 'http://.*(#{hosts.join "|"})[^\"]*\\b' content/ drafts/ | sort -u`

Dir.chdir "video-backup"
urls.split.each do |url|
  puts "backing up #{url}..."
  system "cclive -c --max-retries 0 '#{url}'"
end
