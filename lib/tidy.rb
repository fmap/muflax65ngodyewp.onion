#!/usr/bin/env ruby
# coding: utf-8
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require 'tidy_ffi'

class TidyFilter < Nanoc::Filter
  identifier :tidy
  def run(content, params={})
    TidyFFI::Tidy.new(content,
                      :wrap => 80,
                      :tidy_mark => false,
                      :indent => 1,
                      :char_encoding => "utf8",
                      :hide_comments => true,
                      ).clean
  end
end 
