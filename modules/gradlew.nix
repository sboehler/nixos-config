# creates an FHS user environment which
# allows execution of the gradle wrapper
# and downloaded node.js binaries

{ pkgs }:
(pkgs.buildFHSUserEnv {
  name = "gw";
  targetPkgs = Pkgs: (with pkgs;
  [
    stdenv.cc.cc.lib
    docker_compose
    fontconfig # for phantomjs
    freetype # for phantomjs
    openjdk11
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
    export JAVA_HOME=${pkgs.openjdk11.home}
  '';
  runScript = "zsh";
  })
