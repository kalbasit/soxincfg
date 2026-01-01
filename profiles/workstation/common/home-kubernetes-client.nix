{
  pkgs,
  ...
}:

{
  home.packages = [
    pkgs.argocd
    pkgs.cilium-cli
    pkgs.fluxcd
    pkgs.hubble # Cilium Observability.
    pkgs.k9s
    pkgs.kind # for local dev clusters
    pkgs.kube-capacity
    pkgs.kubeconform
    pkgs.kubectl
    pkgs.kubectl-neat
    pkgs.kubectl-node-shell
    pkgs.kubectl-tree
    pkgs.kubernetes-helm
    pkgs.kubespy
    pkgs.kubeval
    pkgs.kustomize

    pkgs.kubecolor
    (pkgs.writeShellScriptBin "k" ''
      ${pkgs.kubecolor}/bin/kubecolor "$@"
    '')
    (pkgs.writeShellScriptBin "kc" ''
      BG_RED="\033[41m"
      FG_BLACK_B="\033[1;30m"
      FG_CLEAR="\033[0m"
      readonly BG_RED FG_BLACK_B FG_CLEAR

      state_file="$HOME/.local/state/kc-call-count"
      readonly state_file

      if [[ ! -f "$state_file" ]]; then
        mkdir -p "$(dirname "$state_file")"
        echo -n 0 > "$state_file"
      fi

      count="$(tr -d '\n' < "$state_file")"
      count=$(( count + 1 ))

      echo -n "$count" > "$state_file"

      echo -e "$BG_RED$FG_BLACK_B !WARNING!$FG_CLEAR Reminder to use k instead of kc. You made this mistake $count times already"

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
