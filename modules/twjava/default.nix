{ pkgs, config, ... }:
let
  manyLinuxFile =
    pkgs.writeTextDir "_manylinux.py"
      ''
        print("in _manylinux.py")
        manylinux1_compatible = True
      '';
in {
  nixpkgs.config = {

    packageOverrides = pkgs: rec {
      openjdk12 = pkgs.callPackage ./java12.nix {
        inherit (pkgs.gnome2) GConf gnome_vfs;
        bootjdk = pkgs.openjdk11;
      };

      gradleGen = pkgs.gradleGen.override {
        jdk = pkgs.openjdk12;
      };

      gw = pkgs.callPackage ({ pkgs }:

        (pkgs.buildFHSUserEnv {
          name = "gw";
          targetPkgs = pkgs: (with pkgs; [
            coreutils
            dhall
            dhall-json
            docker
            docker_compose
            fontconfig # for phantomjs
            freetype # for phantomjs
            freetype.dev
            gfortran
            git
            libpng
            libpng.dev
            nodejs
            openjdk12
            pkg-config
            python3
            stdenv.cc
            stdenv.cc.cc.lib
            subversion
            zlib # for phantomjs

            # python / scipy stack deps
            python3
            pipenv
            which
            gcc
            binutils
            freetype
            freetype.dev
            gfortran
            pkgconfig
            libpng
            libpng.dev
            zlib
            suitesparse
            blas
            liblapack

            # All the C libraries that a manylinux_1 wheel might depend on:
            ncurses
            xorg.libX11
            xorg.libXext
            xorg.libXrender
            xorg.libICE
            xorg.libSM
            glib
            zsh
          ]);
          profile = ''
           export JAVA_HOME=${pkgs.openjdk12.home}
           export ORG_GRADLE_PROJECT_load=true
           export ORG_GRADLE_PROJECT_noUi=true

           # enable python wheels
           export PYTHONPATH=${manyLinuxFile.out}:/usr/lib/python3.7/site-packages
         '';
          runScript = "$SHELL";
        })) {};
    };
  };

  environment.systemPackages = with pkgs; [
    gw
    openjdk12
  ];

}
