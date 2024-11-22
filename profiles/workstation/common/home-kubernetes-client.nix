{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.argocd
    pkgs.kubecolor
    pkgs.kubeconform
    pkgs.kubectl
    pkgs.kubectl-tree
    pkgs.kubectx
    pkgs.kubernetes-helm
    pkgs.kubespy
    pkgs.kubetail
    pkgs.kubeval
  ];

  programs.zsh.shellAliases = {
    kc = "kubecolor";
  };
}
