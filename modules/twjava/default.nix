{ pkgs, config, ... }:
{
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
         targetPkgs = Pkgs: (with pkgs;
         [
           stdenv.cc.cc.lib
           docker_compose
           fontconfig # for phantomjs
           freetype # for phantomjs
           openjdk12
           coreutils
           stdenv.cc
           docker
           nodejs
           dhall
           dhall-json
           git
           zlib # for phantomjs
           zsh
           ]);
         profile = ''
           export JAVA_HOME=${pkgs.openjdk12.home}
           export ORG_GRADLE_PROJECT_load=true
           export ORG_GRADLE_PROJECT_noUi=true
         '';
         runScript = "zsh";
         })) {};
     };
  };

  environment.systemPackages = with pkgs; [
    pkgs.openjdk12
  ];

}
