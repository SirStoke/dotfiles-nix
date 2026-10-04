{
  config,
  pkgs,
  ...
}: {
  services.prowlarr.enable = true;
  services.prowlarr.dataDir = "/var/data/prowlarr";
}
