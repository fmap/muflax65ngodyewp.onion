#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2011
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

source ~/.zsh/path.sh

grep -roP "http://.*" content drafts | backup-urls
