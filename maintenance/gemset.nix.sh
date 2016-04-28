#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash curl bundix bundler
#: Above includes transitive dependencies of our libraries, would be great to specify them at the usage site.
# workaround for https://github.com/NixOS/nixpkgs/issues/13744
if [[ $SSL_CERT_FILE == "/no-cert-file.crt" ]];
  then unset SSL_CERT_FILE;
fi
source "$(dirname $(realpath $0))/lib/rubygems.sh"
source "$(dirname $(realpath $0))/lib/prelude.sh"

TopLevelDependencies() {
  echo gem \"nanoc\", \"\<4\";
  ( # Nanoc isn't an explicit dependency:
    # We want its filters too; and those aren't referenced in the gemspec.
    # But we really don't need all of them. (There are a lot.)
    # For now they're being incorporated on an ad-hoc basis:
    tr ' ' '\n' <<< "sass kramdown erubis pygments.rb w3c_validators builder";
    # Local requires, hopefully there aren't any gems named differently from their imports.
    grep -Proh "(?<=require ['\"])[^/'\"]+" ..;
  ) | sort -u | Filter IsRubyGem | Map Gem2Gemfile
};

rm -rf Gemfile.lock bundle/ .bundle/ Gemfile gemset.nix

echo "source \"https://rubygems.org\"" > Gemfile
TopLevelDependencies >> Gemfile

bundler package --no-install --path bundle/
rm -rf bundle/ .bundle/ vendor/

bundix

