#!/usr/bin/env ruby
# coding: utf-8
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require 'tidy_ffi'

class TidyFilter < Nanoc::Filter
  identifier :tidy
  def run(content, params={})
    tidy content
  end
end 

def tidy text
  TidyFFI::Tidy.new(text,
                    :wrap => 80,
                    :tidy_mark => false,
                    :indent => 1,
                    :char_encoding => "utf8",
                    :hide_comments => true,
                    :show_body_only => "auto"
                    ).clean
end
