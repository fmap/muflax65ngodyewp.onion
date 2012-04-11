#!/usr/bin/env ruby
# coding: utf-8
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

require "csv"

Countries = {
  "Deutschland" => "DE",
  "Österreich" => "AT",
  "Schweiz" => "CH",
}

Coords = {}

# get PLZ coordinates
Countries.values.each do |country|
  Coords[country] = {}
  CSV.foreach("#{country}.csv") do |row|
    Coords[country][row[0].to_i] = [row[1].to_f, row[2].to_f]
  end
end

def coord_of country, plz
  if Coords[country].include? plz
    Coords[country][plz]
  else # approximate it
    Coords[country].keys.map{|x| [(x - plz).abs, x]}.min[1]
  end
end

kml = File.open("lw-german-survey.kml", "w")
kml.write <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Folder>
<name>German-speaking LW users</name>
EOL


# read form data
CSV.foreach("plz.csv", :headers => true) do |row|
  if Countries.include? row[1]
    country = Countries[row[1]]
    plz = row[2].to_i
    coord = coord_of(country, plz)
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
