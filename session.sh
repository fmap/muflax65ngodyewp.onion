#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

# start a screen session and set up basic tools
screen -dmS nanoc nanoc view
screen -S nanoc -X screen -t watch 1 nanoc watch
screen -S nanoc -X screen -t mc 2 zsh -c mc
screen -S nanoc -X screen 3 zsh

# basic emacs session
emacs-gui Rules

# switch to screen session
screen -r nanoc
