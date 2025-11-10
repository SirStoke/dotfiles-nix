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
    dataDir = "/var/data/jellyfin";
    user = "plex"; # Cannot be bothered
  };
}
