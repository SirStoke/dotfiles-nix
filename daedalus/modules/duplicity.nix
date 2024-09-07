{pkgs, ...}: let
  targetUrl = "s3://daedalus-bkp";
  secretFile = /run/agenix/duplicity-secrets;
  endpointUrl = "https://s3.eu-central-003.backblazeb2.com";
in {
  services.duplicity = {
    inherit targetUrl;
    inherit secretFile;

    enable = true;
    root = /var/data;
    fullIfOlderThan = "1M";
    extraFlags = [
      "--s3-endpoint-url"
      endpointUrl
      "--progress"
      "--progress-rate"
      "60"
    ];
    cleanup.maxFull = 1;
  };

  systemd.timers."duplicity-exporter" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "duplicity-exporter.service";
    };
  };

  systemd.services."duplicity-exporter" = let
    otlpMetricJson = name: description: let
      baseJson = builtins.toJSON {
        resourceMetrics = [
          {
            resource.attributes = [
              {
                key = "service.name";
                value.stringValue = "duplicity-exporter";
              }
            ];
            scopeMetrics = [
              {
                metrics = [
                  {
                    inherit name;
                    inherit description;

                    unit = "1";
                    gauge.dataPoints = [
                      {
                        asDouble = "$metricValue";
                        timeUnixNano = "$timestampNano";
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    in
      builtins.replaceStrings ["\"$metricValue\"" "\"$timestampNano\""] ["$metricValue" "$timestampNano"] baseJson;

    lastBackupJson = otlpMetricJson "last_full_backup" "Last duplicity full backup";
  in {
    script = ''
      DATE_STR="$(${pkgs.duplicity}/bin/duplicity collection-status 's3://daedalus-bkp' --s3-endpoint-url 'https://s3.eu-central-003.backblazeb2.com' | grep 'Last full backup date:' | sed 's/Last full backup date: //g')"
      LAST_FULL_BACKUP=$(date -d "$DATE_STR" '+%s%3N')

      echo "Last full backup: $LAST_FULL_BACKUP"

      TIMESTAMP_NANO="$(date '+%s%N')"
      METRIC_JSON=$(${pkgs.jq}/bin/jq --null-input --argjson metricValue "$LAST_FULL_BACKUP" --arg timestampNano "$TIMESTAMP_NANO" '${lastBackupJson}')

      echo $METRIC_JSON

      ${pkgs.curl}/bin/curl -XPOST http://localhost:4318/v1/metrics -d "$METRIC_JSON" -H 'Content-Type: application/json'
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = secretFile;
    };
  };
}
