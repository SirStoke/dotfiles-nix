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
    # Toggl has restricted API usage,
    # will have to figure something out
    #./toggled
    ./clickhouse
    ./otel-collector
    ./grafana
    ./prometheus-exporters
    ./mealie
  ];
}
