{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.argocd
    pkgs.k9s
    pkgs.kubecolor
    pkgs.kubeconform
    pkgs.kubectl
    pkgs.kubectl-tree
    pkgs.kubectx
    pkgs.kubernetes-helm
    pkgs.kubeseal
    pkgs.kubespy
    pkgs.kubetail
    pkgs.kubeval
    pkgs.kustomize
  ];

  programs.zsh.shellAliases = {
    kc = "kubecolor";
    kcc = "kubectx";
    kcn = "kubens";
    kt = "kubetail";
  };
}
