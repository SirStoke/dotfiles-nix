{
  config,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;

    settings = {};
    dataDir = "/var/data/grafana";
  };
}
