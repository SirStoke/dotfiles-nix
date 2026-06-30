{
  config,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;

    settings = {
      security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
    };
    dataDir = "/var/data/grafana";
  };
}
