#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require "backup-urls"
require "awesome_print"

files = Dir["content/references/*.mkd"]

hosts = [
         /(wiki\.)?lesswrong/,
         /tvtropes\.org/,
        ]

files.each do |file|
  puts "checking #{file} for citations..."
  
  # get all urls
  text = File.read(file)
  urls = text.scan(/https?:\/\/\S+$/)

  # filter unimportant stuff
  urls = BackupUrls.filter_urls(urls)

  # only backup this stuff
  urls = hosts.map{|host| urls.select{|u| u.match host}}.flatten.uniq

  # cite them
  cites = BackupUrls.archive urls

  # replace urls
  cites.each do |url, cite|
    text.gsub! /#{Regexp.quote(url)} (\s | \/ )*$/x, cite
  end

  # save changed file
  File.open(file, "w") {|f| f.puts text}
end
