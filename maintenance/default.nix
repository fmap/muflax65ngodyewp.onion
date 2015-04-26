{ pkgs ? import <nixpkgs> {}
}: let
  inherit (pkgs) 
    callPackage buildRubyGem lib ruby_2_2 libtidy
    perlPackages pythonPackages glibcLocales;
  inherit (lib) optionalAttrs hasAttr mapAttrs;
  hotfix = mapAttrs (_: f: f {}) (callPackage <nixpkgs/pkgs/development/interpreters/ruby/bundler-env/default-gem-config.nix> {}) // {
    tidy_ffi = {
      postInstall = ''
        substituteInPlace $out/lib/ruby/gems/2.2.0/gems/tidy_ffi-0.1.6/lib/tidy_ffi/lib_tidy.rb --replace 'usr' ${libtidy}
      '';
    };
  };
  awesome_print = buildRubyGem ({
    name    = ''awesome_print-1.6.1'';
    sha256  = ''1vwgsgyyq87iwjxi8bwh56fj3bzx7x2vjv1m6yih1fbhnbcyi2qd'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''awesome_print'' hotfix) hotfix.awesome_print);
  builder = buildRubyGem ({
    name    = ''builder-3.2.2'';
    sha256  = ''14fii7ab8qszrvsvhz6z2z3i4dw0h41a62fjr2h1j8m41vbrmyv2'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''builder'' hotfix) hotfix.builder);
  erubis = buildRubyGem ({
    name    = ''erubis-2.7.0'';
    sha256  = ''1fj827xqjs91yqsydf0zmfyw9p4l2jz5yikg3mppz6d7fi8kyrb3'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''erubis'' hotfix) hotfix.erubis);
  image_size = buildRubyGem ({
    name    = ''image_size-1.4.1'';
    sha256  = ''0r42q2mfm2ab05qpl7l1smlj2pwx9v3cajy5j3xz67vs6fg49nmj'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''image_size'' hotfix) hotfix.image_size);
  kramdown = buildRubyGem ({
    name    = ''kramdown-1.7.0'';
    sha256  = ''070r81kz88zw28c8bs5p0p92ymn1nldci2fm1arkas0bnqrd3rna'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''kramdown'' hotfix) hotfix.kramdown);
  nanoc = buildRubyGem ({
    name    = ''nanoc-3.7.5'';
    sha256  = ''00i6h52mmgdgpv3wzb56sk5nn75cl6zvhhapszk12xrykhrhjhsh'';
    gemPath = [cri ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''nanoc'' hotfix) hotfix.nanoc);
  cri = buildRubyGem ({
    name    = ''cri-2.6.1'';
    sha256  = ''0zzwvwzrrlmx6c5j7bqc63ib952h37i357xn97m3h8bjd7zyv79l'';
    gemPath = [colored ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''cri'' hotfix) hotfix.cri);
  colored = buildRubyGem ({
    name    = ''colored-1.2'';
    sha256  = ''0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''colored'' hotfix) hotfix.colored);
  nokogiri = buildRubyGem ({
    name    = ''nokogiri-1.6.6.2'';
    sha256  = ''1j4qv32qjh67dcrc1yy1h8sqjnny8siyy4s44awla8d6jk361h30'';
    gemPath = [mini_portile ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''nokogiri'' hotfix) hotfix.nokogiri);
  mini_portile = buildRubyGem ({
    name    = ''mini_portile-0.6.2'';
    sha256  = ''0h3xinmacscrnkczq44s6pnhrp4nqma7k056x5wv5xixvf2wsq2w'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''mini_portile'' hotfix) hotfix.mini_portile);
  org-ruby = buildRubyGem ({
    name    = ''org-ruby-0.9.12'';
    sha256  = ''0x69s7aysfiwlcpd9hkvksfyld34d8kxr62adb59vjvh8hxfrjwk'';
    gemPath = [rubypants ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''org-ruby'' hotfix) hotfix.org-ruby);
  rubypants = buildRubyGem ({
    name    = ''rubypants-0.2.0'';
    sha256  = ''1vpdkrc4c8qhrxph41wqwswl28q5h5h994gy4c1mlrckqzm3hzph'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''rubypants'' hotfix) hotfix.rubypants);
  pygments.rb = buildRubyGem ({
    name    = ''pygments.rb-0.6.3'';
    sha256  = ''160i761q2z8kandcikf2r5318glgi3pf6b45wa407wacjvz2966i'';
    gemPath = [posix-spawn yajl-ruby ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''pygments.rb'' hotfix) hotfix.pygments.rb);
  posix-spawn = buildRubyGem ({
    name    = ''posix-spawn-0.3.9'';
    sha256  = ''042i1afggy1sv2jmdjjjhyffas28xp2r1ylj5xfv3hchy3b4civ3'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''posix-spawn'' hotfix) hotfix.posix-spawn);
  yajl-ruby = buildRubyGem ({
    name    = ''yajl-ruby-1.2.1'';
    sha256  = ''0zvvb7i1bl98k3zkdrnx9vasq0rp2cyy5n7p9804dqs4fz9xh9vf'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''yajl-ruby'' hotfix) hotfix.yajl-ruby);
  sanitize = buildRubyGem ({
    name    = ''sanitize-4.0.0'';
    sha256  = ''0sk78s5ivpgf7yc6mxcqqs3jjyk8db3yc2rdj1ayi64yc2f5qi2n'';
    gemPath = [crass nokogiri nokogumbo ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''sanitize'' hotfix) hotfix.sanitize);
  crass = buildRubyGem ({
    name    = ''crass-1.0.2'';
    sha256  = ''1c377r8g7m58y22803iyjgqkkvnnii0pymskda1pardxrzaighj9'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''crass'' hotfix) hotfix.crass);
  nokogumbo = buildRubyGem ({
    name    = ''nokogumbo-1.4.1'';
    sha256  = ''0s47jdvfqmcs8bggnk1i8cbrci0k548aygjdamfb9jgfqrl3l552'';
    gemPath = [nokogiri ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''nokogumbo'' hotfix) hotfix.nokogumbo);
  sass = buildRubyGem ({
    name    = ''sass-3.4.13'';
    sha256  = ''0wxkjm41xr77pnfi06cbwv6vq0ypbni03jpbpskd7rj5b0zr27ig'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''sass'' hotfix) hotfix.sass);
  tidy_ffi = buildRubyGem ({
    name    = ''tidy_ffi-0.1.6'';
    sha256  = ''0mz8zr6xvfj2rhznydxqlkkgn9samxlwklc9v2z9bbzl4bzbddi5'';
    gemPath = [ffi ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''tidy_ffi'' hotfix) hotfix.tidy_ffi);
  ffi = buildRubyGem ({
    name    = ''ffi-1.9.8'';
    sha256  = ''0ph098bv92rn5wl6rn2hwb4ng24v4187sz8pa0bpi9jfh50im879'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''ffi'' hotfix) hotfix.ffi);
  w3c_validators = buildRubyGem ({
    name    = ''w3c_validators-1.2'';
    sha256  = ''0kz0y6ki2q0xplxhk1aamp8x2pmgkvkfwhz7g481dg44gqlw5pbb'';
    gemPath = [json nokogiri ];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''w3c_validators'' hotfix) hotfix.w3c_validators);
  json = buildRubyGem ({
    name    = ''json-1.8.2'';
    sha256  = ''0zzvv25vjikavd3b1bp6lvbgj23vv9jvmnl4vpim8pv30z8p6vr5'';
    gemPath = [];
    ruby    = ruby_2_2;
  } // optionalAttrs (hasAttr ''json'' hotfix) hotfix.json);
in pkgs.stdenv.mkDerivation {
  name = "muflax.com";
  src = ../.;
  LC_ALL="en_US.utf8";
  buildInputs =
    [awesome_print builder erubis image_size kramdown nanoc nokogiri org-ruby pygments.rb sanitize sass tidy_ffi w3c_validators ] ++
    [perlPackages.ImageExifTool pythonPackages.pygments glibcLocales];
  patchPhase = ''
    sed -i 's/do$/do |_, _|/' commands/backup/*
  '';
  buildPhase = ''
    nanoc references
    nanoc images
    for site in blog daily gospel muflax; do
      nanoc compile -s $site
      nanoc compress -s $site
    done
  '';
  installPhase = ''
    mv out $out
  '';
}
