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
    # company-lsp
    counsel
    counsel-projectile
    direnv
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
    # use latest from melpa as these are evolving quickly
    # lsp-haskell
    # lsp-mode
    # lsp-ui
    # nix-mode
    magit
    markdown-mode
    neotree
    ox-jira
    org-noter
    ox-gfm
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
  ]) ++ (with epkgs.orgPackages; [
    org
  ]) ++ [
    epkgs.pdf-tools
  ])
