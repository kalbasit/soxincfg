# Soxin v1's modules for one kind of configuration ("nixos", "darwin" or
# "home"), in list.nix's order, as v1's nixosModule imported them.
kind: {
  imports = map (module: if builtins.isAttrs module then module.${kind} else module) (
    builtins.attrValues (import ./list.nix)
  );
}
