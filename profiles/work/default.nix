{
  imports = { hostName }:
    let
      hosts =
        if builtins.pathExists ./secret-store
        then import ./secret-store
        else builtins.trace "WARNING: The secret work files were NOT found" { };
    in
    if builtins.hasAttr hostName hosts
    then builtins.getAttr hostName hosts
    else [ ];
}
