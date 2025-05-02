{
  config,
  pkgs,
  unstablePkgs,
  ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    package = unstablePkgs.jellyfin;
    dataDir = "/var/data/plex";
    user = "plex"; # Cannot be bothered
  };
}
