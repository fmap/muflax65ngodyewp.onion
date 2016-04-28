#! /usr/bin/env bash
source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/prelude.sh"

IsRubyGem() {
  test 200 = "$(curl -sL -w '%{http_code}' https://rubygems.org/api/v1/gems/$1.json -o /dev/null)";
};

Gem2Gemfile() {
  echo gem \"$1\"
}
