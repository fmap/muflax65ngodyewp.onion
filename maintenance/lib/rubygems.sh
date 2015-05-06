#! /usr/bin/env bash

source "$(dirname $(readlink -f ${BASH_SOURCE[0]}))/prelude.sh"

IsRubyGem() {
  test 200 = "$(curl -sL -w '%{http_code}' https://rubygems.org/api/v1/gems/$1.json -o /dev/null)";
};

GetLatestVersion() {
  curl -sL https://rubygems.org/api/v1/gems/$1.json | jq -r '.version'
};

read -r -d '' AWKPrelude <<EOF
 @include "join";
 function unescape(str) {
   gsub("&gt;",">",str);
   gsub("&lt;","<",str);
   gsub(/^= /,"== ",str);
   return str;
 }
 function ver(str) {
   n=split(str,xs,".");
   v=xs[1]; for(i=2;i<=n;i++)
     v+=xs[i]*(10**(1-i));
   return v
 }
 function unwakka(str) {
   if (str ~ /^~>/) {
     sub(/^[^ ]+ */,"",str);
     n=split(str,xs,".");xs[n-1]++;xs[n]=0;
     return(sprintf(">= %s, < %s", str, join(xs,1,n,".")));
   } else return str
 };
EOF

CompileConstraint() {
  awk "$AWKPrelude"'
    NF {
      printf "%s;", $1;
      sub(".*" $1 FS, "");
      sub($0, unwakka(unescape($0)));
      split($0, xs, ", "); for (x in xs)
        split(xs[x],ys," ");
        printf "ver($0) %s %s && ", ys[1], ver(ys[2])
      print "1"
    }
  ';
};

SatisfyConstraint() {
  GemName="$1"; Constraint="$2";
  curl -s https://rubygems.org/api/v1/versions/$GemName.json \
    | jq -r '.[] | .number' \
    | awk "$AWKPrelude ($Constraint){print;exit}"
};

GetDependencies() {
  # The RubyGems API doesn't seem to permit retrieving the dependencies of any
  # version other than the most recent, so we resort to scraping.
  GemName="$1"; GemVersion="$2";
  curl -s https://rubygems.org/gems/$GemName/versions/$GemVersion  \
    | xmllint --xpath '//div[@id="runtime_dependencies"]/div/a//text()' --html 2>/dev/null - \
    | CompileConstraint \
    | { IFS=";"; while read -r Name Constraint; do
        Version="$(SatisfyConstraint "$Name" "$Constraint")"
        test -n "$Name" && test -n "$Version" && echo "$Name" "$Version"
      done; }
};

GetSHA256() {
  nix-prefetch-url https://rubygems.org/downloads/$1.gem 2>/dev/null
};

Gem2Nix() {
  GemName=$1; GemVersion="${2:-$(GetLatestVersion $GemName)}";
  grep -qE "^$GemName" "$GemCache" || {
    echo $GemName >> "$GemCache";
    sed 's/^    //;/^$/d' <<< "
      $GemName = buildRubyGem ({
        name    = ''$GemName-$GemVersion'';
        sha256  = ''$(GetSHA256 $GemName-$GemVersion)'';
        gemPath = [$(GetDependencies "$GemName" "$GemVersion" | cut -d' ' -f1 | tr '\n' ' ')];
        ruby    = ruby_2_2;
      } // optionalAttrs (hasAttr ''$GemName'' hotfix) hotfix.$GemName);
    "; GetDependencies "$GemName" "$GemVersion" | Map Gem2Nix
  };
};
