cfg:

{
  imports = [
    (import ./address-code-scanning-alert.nix cfg)
    (import ./address-gs-comments.nix cfg)
    (import ./address-pr-comments.nix cfg)
    (import ./get-it-done.nix cfg)
    (import ./git.nix cfg)
    (import ./git-spice.nix cfg)
    (import ./gs-submit.nix cfg)
    (import ./lint.nix cfg)
    (import ./monitor-stack-merge.nix cfg)
    (import ./wait-for-coderabbit-review.nix cfg)
  ];
}
