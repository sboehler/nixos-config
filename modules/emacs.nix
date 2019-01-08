{ pkgs }:
let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  ]) ++ (with epkgs.melpaPackages; [
    ansible-vault
    attrap
    auth-source-pass
    avy
    company
    counsel
    counsel-projectile
    expand-region
    flycheck
    flymd
    git-auto-commit-mode
    gradle-mode
    groovy-mode
    haskell-mode
    hindent
    htmlize
    interleave
    nix-update
    ivy
    lsp-haskell
    lsp-mode
    lsp-ui
    magit
    markdown-mode
    neotree
    # nix-mode
    org-noter
    ox-gfm
    paredit
    projectile
    psc-ide
    purescript-mode
    slime
    solarized-theme
    tide
    typescript-mode
    use-package
    web-mode
    whole-line-or-region
    yaml-mode
  ]) ++ (with epkgs.elpaPackages; [
    csv-mode
  ]) ++ (with epkgs.orgPackages; [
    org
  ]) ++ [
    epkgs.pdf-tools
  ])
