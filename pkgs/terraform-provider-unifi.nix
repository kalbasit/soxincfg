{ buildGoModule, fetchFromGitHub, lib, ... }:

# copied from nixpkgs
let
  buildWithGoModule = data:
    buildGoModule {
      pname = data.repo;
      version = data.version;
      subPackages = [ "." ];
      src = fetchFromGitHub {
        inherit (data) owner repo rev sha256;
      };
      vendorSha256 = data.vendorSha256 or null;

      # Terraform allow checking the provider versions, but this breaks
      # if the versions are not provided via file paths.
      postBuild = "mv $NIX_BUILD_TOP/go/bin/${data.repo}{,_v${data.version}}";
      passthru = data;
    };
in
buildWithGoModule rec {
  owner = "paultyng";
  repo = "terraform-provider-unifi";
  rev = "v${version}";
  sha256 = "sha256-DkcKL6zt4nTfYqfIPdRMaOn3DwzFa8FYnzRVH8g7xig=";
  vendorSha256 = "sha256-DDjfbWP/rovh5ZP2LlR9mZKh7rukhXy3s0ajdQQmQeY=";
  version = "0.18.2";
}
