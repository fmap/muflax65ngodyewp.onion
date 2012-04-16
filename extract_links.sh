#!/bin/zsh
# Copyright muflax <mail@muflax.com>, 2012
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>

grep -ahorP '(https?[.:][^ >"\t]*|www\.[-a-z0-9.]+)[^ .,;\t>">\):]' content*/**/*.(mkd|org)

