{
  description = "muflax.com static site generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) lib ruby bundlerEnv html-tidy perlPackages python3Packages glibcLocales;

      gemconfig = {
        tidy_ffi = attrs: {
          dontBuild = false;
          postPatch = ''
            substituteInPlace lib/tidy_ffi/lib_tidy.rb --replace-warn 'usr' ${html-tidy}
          '';
        };
      };

      muflax-env = bundlerEnv {
        name = "muflax-blog-env";
        gemConfig = pkgs.defaultGemConfig // gemconfig;
        inherit ruby;
        gemfile = ./maintenance/Gemfile;
        lockfile = ./maintenance/Gemfile.lock;
        gemset = ./maintenance/gemset.nix;
      };
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "muflax.com";
        src = ./.;
        LC_ALL = "en_US.UTF-8";
        buildInputs = [
          muflax-env
          perlPackages.ImageExifTool
          python3Packages.pygments
          glibcLocales
        ];
        patchPhase = ''
          sed -i 's/do$/do |_, _|/' commands/backup/*
        '';
        buildPhase = ''
          nanoc references
          nanoc images
          for site in blog daily gospel muflax; do
            nanoc compile -s $site
          done
        '';
        installPhase = ''
          mv out $out
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        LC_ALL = "en_US.UTF-8";
        buildInputs = [
          muflax-env
          ruby
          perlPackages.ImageExifTool
          python3Packages.pygments
          glibcLocales
        ];
      };
    };
}
