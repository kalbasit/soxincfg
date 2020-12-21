{ ... }:

{
  # Add the extra hosts
  networking.extraHosts = ''
    127.0.0.1 docker.keeptruckin.dev docker.keeptruckin.work
  '';

  nix = {
    binaryCaches = [ "https://nix-cache.corp.ktdev.io" ];
    binaryCachePublicKeys = [ "nix-cache.corp.ktdev.io:/xiDfugzrYzUtdUEIvdYBHy48O0169WYHYb/zMdWgLA=" ];
  };
}
