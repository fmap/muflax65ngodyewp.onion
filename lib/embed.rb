require 'image_size'

def image(name, title="")
  # all images are stored at content/pigs and only the main site routes them

  img = ImageSize.new IO.read("content/pigs/#{name}")
  "<img src='/pigs/#{name}' height='#{img.height}' width='#{img.width}' title='#{title}' alt='#{title}'/>"
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

