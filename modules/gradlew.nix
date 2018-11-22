# creates an FHS user environment which
# allows execution of the gradle wrapper
# and downloaded node.js binaries

{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "gw";
  targetPkgs = Pkgs: (with pkgs;
  [
    stdenv.cc.cc.lib
    docker_compose
    fontconfig # for phantomjs
    freetype # for phantomjs
    openjdk11
    stdenv.cc
    docker
    git
    zlib # for phantomjs
    zsh
    ]);
  profile = ''
    export JAVA_HOME=${pkgs.openjdk11.home}
  '';
  runScript = "./gradlew";
  })
