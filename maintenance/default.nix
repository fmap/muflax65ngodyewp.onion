{ pkgs ? import <nixpkgs> {}
}: let
  inherit (pkgs) 
    lib ruby_2_2 libtidy bundlerEnv defaultGemConfig
    perlPackages pythonPackages glibcLocales;

gemconfig = {
  tidy_ffi = attrs: {
    dontBuild = false;
    postPatch = ''
      ls -R
      substituteInPlace lib/tidy_ffi/lib_tidy.rb --replace 'usr' ${libtidy}
    '';
  };
};
muflax-env = bundlerEnv {
  name = "muflax-blog-env";
  gemConfig = defaultGemConfig // gemconfig;
  ruby = ruby_2_2;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;
};
in pkgs.stdenv.mkDerivation {
  name = "muflax.com";
  src = ../.;
  LC_ALL="en_US.UTF-8";
  buildInputs =
    [muflax-env] ++
    [perlPackages.ImageExifTool pythonPackages.pygments glibcLocales];
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
}
