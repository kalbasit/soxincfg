{
  imports = { hostName }:
    let
      hosts =
        if builtins.pathExists ./secret-store
        then import ./secret-store
        else { };
    in
    if hosts == { }
    then builtins.trace "WARNING: The secret work files were NOT found" [ ]
    else if builtins.hasAttr hostName hosts
    then builtins.getAttr hostName hosts
    else builtins.trace "WARNING: No secrets were found for host ${hostName}." [ ];
}
