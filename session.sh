#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

site=$1

if [[ -z $1 ]]; then
  echo "defaulting to daily..."
  site="daily"
fi

if [[ $site -eq "daily" ]]; then
  # work on last log
  nanoc last
fi

# start a screen session and set up basic tools
tmux new-session "nanoc view -s $site" \; \
  neww "nanoc watch -s $site" \; \
  set default-path "$(pwd)" \; set -g -a update-environment ' PWD' \; \
  neww
