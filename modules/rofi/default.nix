{ pkgs, stdenv }:
let
  scripts = ./scripts;
in
  pkgs.writeShellScriptBin "launch-rofi" ''
    TERM=dumb
    ls ${scripts} | ${pkgs.rofi}/bin/rofi -dmenu -normal-window | xargs -I TARGET bash ${scripts}/TARGET
  ''
