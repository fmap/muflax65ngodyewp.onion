#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

setopt RE_MATCH_PCRE

if [[ -z $1 ]]; then
  echo "usage: $0 site"
  exit 1
fi

echo "compressing site: $1..."

for f in out/$1/**/*(.); do
  if [[ $f =~ "\.(html|css|xml|js)$" ]]; then
    gzip --best -f -v -c "$f" > "$f.gz" 
  fi
done
