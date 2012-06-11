require 'image_size'
require 'set'

def image(name, title="", link=nil)
  # all images are stored at content/pigs and only the main site routes them
  ret = ""

  # read image size
  img = ImageSize.new IO.read("content_#{@site.name}/pigs/#{name}")
  
  # if it's too large, redirect to smaller version (which is generated with 'nanoc images')
  if img.width > 400 and not name.end_with? ".gif"
    link = "/pigs/#{name}" if link.nil? # link to big version
    name.gsub! /^(.+)\.(\w+)$/, '\1_small.\2'
    img = ImageSize.new IO.read("content_#{@site.name}/pigs/#{name}") # re-read image
  end

  ret += "<a href='#{link}'>" unless link.nil?
  ret += "<img src='/pigs/#{name}' height='#{img.height}' width='#{img.width}' title=\"#{title}\" alt=\"#{title}\"/>"
  ret += "</a>" unless link.nil?
  
  ret
end

def youtube(url)
  <<EOL
<div align="center">
  <object width="420" height="315">
    <param name="movie" value="#{url}"></param>
    <param name="allowFullScreen" value="true"></param>
    <param name="allowscriptaccess" value="always"></param>
    <embed src="#{url}" type="application/x-shockwave-flash" width="420" height="315" allowscriptaccess="always" allowfullscreen="true"></embed>
  </object>
</div>
EOL
end

def dailymotion(url)
  <<EOL
<div align="center">
  <object width="480" height="327">
    <param name="movie" WWvalue="#{url}" />
    <param name="allowFullScreen" value="true" />
    <param name="allowScriptAccess" value="always" />
    <embed type="application/x-shockwave-flash" width="480" height="327" src="#{url}" allowfullscreen="true" allowscriptaccess="always"></embed>
  </object>
</div>
EOL
end

def google_video(url)
  <<EOL
<div align="center">
  <object id="VideoPlayback" style="width: 400px; height: 326px;" width="100" height="100" classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0">
    <param name="src" value="#{url}" />
    <param name="allowfullscreen" value="true" />
    <embed id="VideoPlayback" style="width: 400px; height: 326px;" width="100" height="100" type="application/x-shockwave-flash" src="#{url}" allowfullscreen="true" />
  </object>
</div>
EOL
end

def vimeo(url)
  <<EOL
<div align="center">
  <iframe src="#{url}?portrait=0&amp;color=000000" frameborder="0" width="400" height="320">
  </iframe> 
</div>
EOL
end

def goanimate(uid)
  <<EOL
<div align="center">
  <iframe scrolling="no" allowTransparency="true" frameborder="0" width="400" height="258" src="http://goanimate.com/player/embed/#{uid}"></iframe>
</div>
EOL
end
