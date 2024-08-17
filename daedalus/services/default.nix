{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./baserow
    ./caddy
    ./deluge
    ./jackett
    ./plex
    ./radarr
    ./sonarr
    ./bazarr
  ];
}
