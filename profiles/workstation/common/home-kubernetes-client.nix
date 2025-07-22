{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.argocd
    pkgs.k9s
    pkgs.kubeconform
    pkgs.kubectl
    pkgs.kubectl-neat
    pkgs.kubectl-tree
    pkgs.kubernetes-helm
    pkgs.kubespy
    pkgs.kubeval
    pkgs.kustomize

    pkgs.kubecolor
    (pkgs.writeShellScriptBin "k" ''
      ${pkgs.kubecolor}/bin/kubecolor "$@"
    '')

    pkgs.kubectx
    (pkgs.writeShellScriptBin "kcc" ''
      ${pkgs.kubectx}/bin/kubectx "$@"
    '')
    (pkgs.writeShellScriptBin "kcn" ''
      ${pkgs.kubectx}/bin/kubens "$@"
    '')

    pkgs.kubeseal
    (pkgs.writeShellScriptBin "ks" ''
      ${pkgs.kubeseal}/bin/kubeseal "$@"
    '')

    pkgs.kubetail
    (pkgs.writeShellScriptBin "kt" ''
      ${pkgs.kubetail}/bin/kubetail "$@"
    '')
  ];
}
