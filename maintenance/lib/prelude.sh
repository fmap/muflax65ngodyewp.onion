#! /usr/bin/env bash

Map() {
  while read Line; do $* $Line; done
};

Filter() {
  X() { $* && (shift; echo $*;) }; Map X $*
};
