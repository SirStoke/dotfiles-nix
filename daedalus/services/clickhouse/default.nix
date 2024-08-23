{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers = {
    clickhouse = {
      image = "clickhouse/clickhouse-server:24.7.4.51-alpine";

      volumes = [
        "/var/data/clickhouse:/var/lib/clickhouse"
        "/var/data/clickhouse-logs:/var/log/clickhouse-server"
      ];

      ports = [
        "127.0.0.1:18123:8123"
        "127.0.0.1:19000:9000"
      ];

      extraOptions = [
        "--ulimit"
        "nofile=262144:262144"
        "--cap-add=SYS_NICE"
        "--cap-add=NET_ADMIN"
        "--cap-add=IPC_LOCK"
      ];
    };
  };
}
