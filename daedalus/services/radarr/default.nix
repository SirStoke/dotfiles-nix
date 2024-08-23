{
  config,
  pkgs,
  ...
}: {
  services.radarr = {
    enable = true;

    dataDir = "/var/data/radarr";
  };

  services.prometheus.exporters.exportarr-radarr = {
    enable = true;
    apiKeyFile = config.age.secrets.radarr-api-key.path;
    url = "http://127.0.0.1:7878";
    port = 9709;

    user = "radarr";
    group = "media";
  };
}
