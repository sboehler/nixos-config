{ pkgs ? import <nixpkgs> {} }:
let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  ]) ++ (with epkgs.melpaPackages; [
    use-package
    solarized-theme
    whole-line-or-region
    company
    flycheck
    ivy
    counsel
    magit
    neotree
    git-auto-commit-mode
    ox-gfm
    pdf-tools
    interleave
    org-noter
    projectile
    counsel-projectile
    expand-region
    avy
    auth-source-pass
    haskell-mode
    lsp-ui
    lsp-mode
    lsp-haskell
    attrap
    hindent
    nix-mode
    typescript-mode
    tide
    web-mode
    paredit
    slime
    purescript-mode
    psc-ide
    yaml-mode
    gradle-mode
    groovy-mode
    markdown-mode
    flymd
    ansible-vault
  ]) ++ (with epkgs.elpaPackages; [
    csv-mode
  ]) ++ [
  ])
