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

  settingsFormat = pkgs.formats.yaml {};

  settings = {
    receivers = {
      prometheus.config.scrape_configs = [
        (exporter "sonarr" 9708)
        (exporter "radarr" 9709)
        (exporter "systemd" 9558)
        (exporter "zfs" 9134)
        (exporter "deluge" 9354)
      ];

      otlp.protocols = {
        http.endpoint = "127.0.0.1:4318";
      };
    };

    exporters.clickhouse = {
      endpoint = "tcp://127.0.0.1:19000";
      database = "metrics";
      compress = "lz4";
      create_schema = true;
    };

    service.pipelines.metrics = {
      receivers = ["prometheus" "otlp"];
      exporters = ["clickhouse"];
    };
  };
in {
  environment.etc."opentelemetry-collector/wait-for-9000.sh" = {
    text = ''
      #!/bin/sh
      # Wait until port 19000 is bound
      while ! ${lib.getExe pkgs.netcat} -z 127.0.0.1 19000; do
        echo "Waiting for port 19000..."
        sleep 1
      done
    '';
    mode = "0755";
  };

  systemd.services.opentelemetry-collector = {
    description = "Opentelemetry Collector Service Daemon";
    wantedBy = ["multi-user.target"];

    serviceConfig = let
      conf = settingsFormat.generate "config.yaml" settings;
    in {
      ExecStartPre = ["/etc/opentelemetry-collector/wait-for-9000.sh"];
      ExecStart = "${lib.getExe pkgs.opentelemetry-collector-contrib} --config=file:${conf}";
      DynamicUser = true;
      Restart = "always";
      ProtectSystem = "full";
      DevicePolicy = "closed";
      NoNewPrivileges = true;
      WorkingDirectory = "%S/opentelemetry-collector";
      StateDirectory = "opentelemetry-collector";
      SupplementaryGroups = [
        # allow to read the systemd journal for opentelemetry-collector
        "systemd-journal"
      ];
    };
  };
}
