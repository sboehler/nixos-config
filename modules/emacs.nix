{ pkgs }:
let
  myEmacs = pkgs.emacs;
  emacsWithPackages = (pkgs.emacsPackagesNgGen myEmacs).emacsWithPackages;

in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
  ]) ++ (with epkgs.melpaPackages; [
    # company-lsp
    # lsp-haskell
    # lsp-mode
    # lsp-ui
    # nix-mode
    # use latest from melpa as these are evolving quickly
    ansible-vault
    attrap
    auth-source-pass
    avy
    company
    counsel
    counsel-projectile
    direnv
    dired-subtree
    dired-avfs
    dired-ranger
    dired-collapse
    dired-narrow
    dired-open
    expand-region
    flycheck
    flymd
    git-auto-commit-mode
    god-mode
    gradle-mode
    groovy-mode
    haskell-mode
    hindent
    htmlize
    interleave
    ivy
    ivy-hydra
    magit
    markdown-mode
    neotree
    nix-update
    org-noter
    ox-gfm
    ox-jira
    paperless
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
    which-key
    whole-line-or-region
    yaml-mode
  ]) ++ (with epkgs.elpaPackages; [
    csv-mode
    orgalist
  ]) ++ (with epkgs.orgPackages; [
    org
  ]) ++ [
    epkgs.pdf-tools
  ])
