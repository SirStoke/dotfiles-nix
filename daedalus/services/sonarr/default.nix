{
  config,
  pkgs,
  ...
}: {
  services.sonarr = {
    enable = true;

    dataDir = "/var/data/sonarr";
  };

  services.prometheus.exporters.exportarr-sonarr = {
    enable = true;
    apiKeyFile = config.age.secrets.sonarr-api-key.path;
    url = "http://127.0.0.1:8989";

    user = "sonarr";
    group = "media";
  };
}
