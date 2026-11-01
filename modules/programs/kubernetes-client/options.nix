{ lib, ... }:

{
  options.soxincfg.programs.kubernetes-client.enable = lib.mkEnableOption ''
    the Kubernetes client tools (kubectl, helm, k9s, kustomize, flux, argocd,
    cilium and friends) with short wrappers: k (kubecolor), kcc (kubectx),
    kcn (kubens), ks (kubeseal) and kt (kubetail)
  '';
}
