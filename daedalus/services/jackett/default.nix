{
  config,
  pkgs,
  ...
}: {
  services.jackett.enable = true;
  services.jackett.dataDir = "/var/data/jackett";
}
