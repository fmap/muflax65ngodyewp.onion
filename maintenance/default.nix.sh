#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash curl gnugrep jq gawk libxml2 nix-prefetch-scripts
#: Above includes transitive dependencies of our libraries, would be great to specify them at the usage site.

GemCache="$(mktemp ${TMPDIR:-/tmp}/GEMS.XXXXXXX)"
source "$(dirname $(realpath $0))/lib/rubygems.sh"
source "$(dirname $(realpath $0))/lib/prelude.sh"

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
  LC_ALL="en_US.UTF-8";
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
