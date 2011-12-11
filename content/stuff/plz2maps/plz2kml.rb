#!/usr/bin/env ruby
# coding: utf-8
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require "csv"

Coords = {}

# get PLZ coordinates
CSV.foreach("plz-coords.csv") do |row|
  Coords[row[0].to_i] = [row[1].to_f, row[2].to_f]
end

def coord_of plz
  if Coords.include? plz
    Coords[plz]
  else # approximate it
    Coords.keys.map{|x| [(x - plz).abs, x]}.min[1]
  end
end

kml = File.open("lw-germany.kml", "w")
kml.write <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Folder>
<name>German LW users</name>
EOL


# read form data
CSV.foreach("plz.csv", :headers => true) do |row|
  if row[1] == "Deutschland"
    plz = row[2].to_i
    coord = coord_of plz
    kml.write <<EOL
<Placemark>
  <name>#{row[0]}</name>
  <Point>
    <coordinates>#{coord[0]},#{coord[1]}</coordinates>
  </Point>
</Placemark>
EOL
  end
end

kml.write <<EOL
</Folder>
</kml>
EOL
