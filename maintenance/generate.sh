#!/usr/bin/env bash

IsRubyGem() {
  test 200 = "$(curl -sL -w '%{http_code}' https://rubygems.org/api/v1/gems/$1.json -o /dev/null)";
};

Map() {
  while read Line; do $* $Line; done
};

Filter() {
  X() { $* && (shift; echo $*;) }; Map X $*
};

TopLevelDependencies() {
  ( # Nanoc isn't an explicit dependency:
    echo nanoc;
    # We want its filters too; and those aren't referenced in the gemspec.
    # But we really don't need all of them. (There are a lot.)
    # For now they're being incorporated on an ad-hoc basis:
    tr ' ' '\n' <<< "sass kramdown erubis pygments.rb w3c_validators builder";
    # Local requires, hopefully there aren't any gems named differently from their imports.
    grep -Proh "(?<=require ['\"])[^/'\"]+" ..;
  ) | sort -u | Filter IsRubyGem
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

GemCache="$(mktemp ${TMPDIR:-/tmp}/GEMS.XXXXXXX)";

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

cat <<EOF
{ pkgs ? import <nixpkgs> {}
}: let
  inherit (pkgs) 
    callPackage buildRubyGem lib ruby_2_2 libtidy
    perlPackages pythonPackages glibcLocales;
  inherit (lib) optionalAttrs hasAttr mapAttrs;
  hotfix = mapAttrs (_: f: f {}) (callPackage <nixpkgs/pkgs/development/interpreters/ruby/bundler-env/default-gem-config.nix> {}) // {
    tidy_ffi = {
      postInstall = ''
        substituteInPlace \$out/lib/ruby/gems/2.2.0/gems/tidy_ffi-0.1.6/lib/tidy_ffi/lib_tidy.rb --replace 'usr' \${libtidy}
      '';
    };
  };
EOF
TopLevelDependencies | Map Gem2Nix
cat <<EOF
in pkgs.stdenv.mkDerivation {
  name = "muflax.com";
  src = ../.;
  LC_ALL="en_US.utf8";
  buildInputs =
    [$(TopLevelDependencies | tr '\n' ' ')] ++
    [perlPackages.ImageExifTool pythonPackages.pygments glibcLocales];
  patchPhase = ''
    sed -i 's/do$/do |_, _|/' commands/backup/*
  '';
  buildPhase = ''
    nanoc references
    nanoc images
    for site in blog daily gospel muflax; do
      nanoc compile -s \$site
      nanoc compress -s \$site
    done
  '';
  installPhase = ''
    mv out \$out
  '';
}
EOF
