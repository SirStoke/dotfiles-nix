{
  config,
  pkgs,
  ...
}: {
  services.radarr = {
    enable = true;

    dataDir = "/var/data/radarr";
  };
}
