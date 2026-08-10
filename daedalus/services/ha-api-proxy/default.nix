{
  lib,
  pkgs,
  ...
}: let
  listenPort = 18124;
  tokenDirectory = "/var/data/secrets";
  tokenFile = "/var/data/secrets/ha_token";

  # Add entries as `endpoint-name = "script.entity_id";`. Call them with:
  #   curl -X POST https://ha-trigger.sirstoke.me/scripts/endpoint-name
  scripts = {
    # bedtime = "script.bedtime";
  };

  # Add entries as `endpoint-name = "automation.entity_id";`. Call them with:
  #   curl -X POST https://ha-trigger.sirstoke.me/automations/endpoint-name
  automations = {
    # arrival = "automation.arrival";
  };

  validEndpoint = endpoint: builtins.match "[a-z0-9][a-z0-9_-]*" endpoint != null;
  validEntity = kind: entity: builtins.match "${kind}\\.[a-z0-9_]+" entity != null;

  mkLocation = kind: service: endpoint: entity: let
    body = builtins.toJSON {entity_id = entity;};
  in ''
    location = /${kind}/${endpoint} {
      limit_except POST { deny all; }
      limit_req zone=ha_trigger burst=5 nodelay;

      # Clear caller-supplied query parameters before constructing the HA request.
      set $args "";
      proxy_pass http://steamdeck:8123/api/services/${service};
      proxy_http_version 1.1;
      proxy_set_header Host steamdeck:8123;
      proxy_set_header Authorization "Bearer $ha_token";
      proxy_set_header Content-Type application/json;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_buffering off;
      proxy_pass_request_body off;
      proxy_set_body '${body}';
    }
  '';

  locations = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (mkLocation "scripts" "script/turn_on") scripts
    ++ lib.mapAttrsToList (mkLocation "automations" "automation/trigger") automations
  );

  configTemplate = pkgs.writeText "ha-api-proxy-nginx.conf.in" ''
    worker_processes 1;
    pid /run/ha-api-proxy/nginx.pid;
    error_log stderr warn;

    events { worker_connections 128; }

    http {
      access_log off;
      server_tokens off;
      client_max_body_size 1;
      limit_req_zone $binary_remote_addr zone=ha_trigger:64k rate=1r/s;

      server {
        listen 127.0.0.1:${toString listenPort};
        server_name _;

        # The default is deny-all; generated exact locations are the only exceptions.
        location / { return 404; }

        ${locations}
      }
    }
  '';

  prepareConfig = pkgs.writeShellScript "prepare-ha-api-proxy-config" ''
    set -eu
    umask 077

    if [ "$(${pkgs.coreutils}/bin/stat -c %u ${tokenDirectory})" != 0 ] \
      || ${pkgs.findutils}/bin/find ${tokenDirectory} -maxdepth 0 -perm /022 -print -quit \
        | ${pkgs.gnugrep}/bin/grep -q .; then
      echo "Home Assistant secret directory must be root-owned and not writable by group or others" >&2
      exit 1
    fi
    if [ ! -f ${tokenFile} ] || [ -L ${tokenFile} ]; then
      echo "Home Assistant token must be a regular, non-symlink file" >&2
      exit 1
    fi
    if [ "$(${pkgs.coreutils}/bin/stat -c %u ${tokenFile})" != 0 ]; then
      echo "Home Assistant token must be owned by root" >&2
      exit 1
    fi
    if ${pkgs.findutils}/bin/find ${tokenFile} -perm /077 -print -quit \
      | ${pkgs.gnugrep}/bin/grep -q .; then
      echo "Home Assistant token must not be accessible by group or others" >&2
      exit 1
    fi

    ha_token="$(${pkgs.coreutils}/bin/cat ${tokenFile})"
    case "$ha_token" in
      ""|*[!A-Za-z0-9._~-]*)
        echo "Home Assistant token contains invalid characters" >&2
        exit 1
        ;;
    esac
    if [ "''${#ha_token}" -lt 20 ] || [ "''${#ha_token}" -gt 4096 ]; then
      echo "Home Assistant token has an implausible length" >&2
      exit 1
    fi

    # envsubst replaces only this variable, leaving nginx's own $variables intact.
    export ha_token
    ${pkgs.gettext}/bin/envsubst '$ha_token' \
      < ${configTemplate} > /run/ha-api-proxy/nginx.conf.tmp
    ${pkgs.coreutils}/bin/chown ha-api-proxy:ha-api-proxy /run/ha-api-proxy/nginx.conf.tmp
    ${pkgs.coreutils}/bin/chmod 0400 /run/ha-api-proxy/nginx.conf.tmp
    ${pkgs.coreutils}/bin/mv /run/ha-api-proxy/nginx.conf.tmp /run/ha-api-proxy/nginx.conf
  '';
in {
  assertions =
    (lib.mapAttrsToList (endpoint: entity: {
        assertion = validEndpoint endpoint && validEntity "script" entity;
        message = "Invalid Home Assistant script proxy endpoint or entity: ${endpoint} -> ${entity}";
      })
      scripts)
    ++ (lib.mapAttrsToList (endpoint: entity: {
        assertion = validEndpoint endpoint && validEntity "automation" entity;
        message = "Invalid Home Assistant automation proxy endpoint or entity: ${endpoint} -> ${entity}";
      })
      automations);

  systemd.services.ha-api-proxy = {
    description = "Allowlisted Home Assistant API proxy";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      RuntimeDirectory = "ha-api-proxy";
      RuntimeDirectoryMode = "0700";
      ExecStartPre = [
        "+${prepareConfig}"
        "${pkgs.nginx}/bin/nginx -t -e stderr -c /run/ha-api-proxy/nginx.conf"
      ];
      ExecStart = "${pkgs.nginx}/bin/nginx -e stderr -c /run/ha-api-proxy/nginx.conf -g 'daemon off;'";
      User = "ha-api-proxy";
      Group = "ha-api-proxy";
      Restart = "on-failure";
      UMask = "0077";
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      RestrictSUIDSGID = true;
    };
  };

  users.groups.ha-api-proxy = {};
  users.users.ha-api-proxy = {
    isSystemUser = true;
    group = "ha-api-proxy";
  };
}
