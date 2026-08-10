{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./airtrail
    ./baserow
    ./caddy
    ./deluge
    ./jackett
    ./plex
    ./jellyfin
    ./radarr
    ./sonarr
    ./unmanic
    ./bazarr
    # Toggl has restricted API usage,
    # will have to figure something out
    #./toggled
    ./clickhouse
    ./otel-collector
    ./grafana
    ./ha-api-proxy
    ./hermes-agent
    ./prometheus-exporters
    ./mealie
    ./anisette
    ./nginx-cors
    ./byparr
    ./prowlarr
    ./postgrest
  ];
}
