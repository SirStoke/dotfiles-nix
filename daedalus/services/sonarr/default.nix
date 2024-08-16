{
  config,
  pkgs,
  ...
}: {
  services.sonarr = {
    enable = true;

    dataDir = "/var/data/sonarr";
  };
}
