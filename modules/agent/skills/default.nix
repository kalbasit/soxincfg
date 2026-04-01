cfg:

{
  imports = [
    (import ./address-code-scanning-alert.nix cfg)
    (import ./address-pr-comments.nix cfg)
    (import ./git.nix cfg)
    (import ./git-spice.nix cfg)
    (import ./lint.nix cfg)
  ];
}
