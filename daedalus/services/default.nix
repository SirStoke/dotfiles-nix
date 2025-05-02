{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./baserow
    ./caddy
    ./deluge
    ./jackett
    ./plex
    ./jellyfin
    ./radarr
    ./sonarr
    ./bazarr
    ./toggled
    ./clickhouse
    ./otel-collector
    ./grafana
    ./prometheus-exporters
    ./mealie
  ];
}
