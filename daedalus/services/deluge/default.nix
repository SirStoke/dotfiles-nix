{
  config,
  pkgs,
  ...
}: let
  # nixos-26.05 ships vulnerable libtorrent 2.0.12; see the upstream wait_for_alert
  # backport https://github.com/arvidn/libtorrent/pull/8313 and nixpkgs update
  # https://github.com/NixOS/nixpkgs/pull/529737. Remove once stable contains 2.0.13+.
  libtorrent-rasterbar = pkgs.libtorrent-rasterbar.overrideAttrs (finalAttrs: {
    version = "2.0.13";
    src = pkgs.fetchFromGitHub {
      owner = "arvidn";
      repo = "libtorrent";
      tag = "v${finalAttrs.version}";
      fetchSubmodules = true;
      hash = "sha256-0L7C3IY/XA+/vLJjZr47aFdYypevhMn1tzZNvDtOjbw=";
    };
  });
in {
  services.deluge = {
    enable = true;
    package = pkgs.deluged.override {inherit libtorrent-rasterbar;};
    web.enable = true;

    dataDir = "/var/data/deluge";
    group = "media";
  };
}
