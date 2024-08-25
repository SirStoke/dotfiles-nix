{
  config,
  pkgs,
  lib,
  ...
}: let
  exporter_path = name: port: path: {
    job_name = name;

    scrape_interval = "5m";

    metrics_path = path;
    scheme = "http";

    static_configs = [
      {
        targets = ["127.0.0.1:${toString port}"];
      }
    ];
  };

  exporter = name: port: exporter_path name port "/metrics";

  otel-contrib = let
    version = "0.107.0";

    src = pkgs.fetchFromGitHub {
      owner = "open-telemetry";
      repo = "opentelemetry-collector-contrib";
      rev = "v${version}";
      sha256 = "sha256-U6ZewP0J8Ib2IY46KBv4xwLMWbREqx4IesJ2Q8geDjM=";
    };
  in
    # buildGoModule doesn't support overrideAttrs, and life is painful like that sometimes
    pkgs.opentelemetry-collector-contrib.override rec {
      buildGoModule = args:
        pkgs.buildGoModule (args
          // {
            inherit src version;
            vendorHash = "sha256-eA2LtZYmRuDtitJ8ValmXfCT116cJBR9KyWcpxGnNx4=";
          });
    };
in {
  services.opentelemetry-collector = {
    enable = true;
    package = otel-contrib;

    settings = {
      receivers.prometheus.config.scrape_configs = [
        (exporter "sonarr" 9708)
        (exporter "radarr" 9709)
        (exporter "systemd" 9558)
        (exporter "zfs" 9134)
      ];

      exporters.clickhouse = {
        endpoint = "tcp://127.0.0.1:19000";
        database = "metrics";
        compress = "lz4";
        create_schema = true;
      };

      service.pipelines.metrics = {
        receivers = ["prometheus"];
        exporters = ["clickhouse"];
      };
    };
  };
}
