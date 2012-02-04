#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

setopt RE_MATCH_PCRE

echo "compressing 'out'..."

for f in out/**/*(.); do
  if [[ $f =~ "\.(html|css|xml|js)$" ]]; then
    gzip --best -f -v -c "$f" > "$f.gz" 
  fi
done
