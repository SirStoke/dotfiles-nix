{pkgs, ...}: let
  initSql = pkgs.writeText "postgrest-init.sql" ''
    create schema if not exists api;

    create role web_anon nologin;
    grant usage on schema api to web_anon;

    create table if not exists api.health (
      ok boolean primary key default true,
      checked_at timestamptz not null default now()
    );

    insert into api.health (ok)
      values (true)
      on conflict (ok) do update set checked_at = now();

    grant select on api.health to web_anon;
    grant web_anon to postgrest;
  '';
in {
  systemd.services.podman-postgrest-network = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists postgrest || podman network create postgrest
    '';
  };

  systemd.services.podman-postgrest-postgres = {
    after = ["podman-postgrest-network.service"];
    requires = ["podman-postgrest-network.service"];
  };

  systemd.services.podman-postgrest = {
    after = [
      "podman-postgrest-network.service"
      "podman-postgrest-postgres.service"
    ];
    requires = ["podman-postgrest-network.service"];
  };

  virtualisation.oci-containers.containers = {
    postgrest-postgres = {
      image = "postgres:16-alpine";
      volumes = [
        "/var/data/postgrest/postgres:/var/lib/postgresql/data"
        "${initSql}:/docker-entrypoint-initdb.d/001-init.sql:ro"
      ];
      environment = {
        POSTGRES_DB = "postgrest";
        POSTGRES_USER = "postgrest";
        POSTGRES_PASSWORD = "postgrest";
      };
      extraOptions = ["--network=postgrest"];
    };

    postgrest = {
      image = "postgrest/postgrest:v12.2.8";
      ports = ["127.0.0.1:3001:3000"];
      dependsOn = ["postgrest-postgres"];
      environment = {
        PGRST_DB_URI = "postgres://postgrest:postgrest@postgrest-postgres:5432/postgrest";
        PGRST_DB_SCHEMA = "api";
        PGRST_DB_ANON_ROLE = "web_anon";
        PGRST_SERVER_PORT = "3000";
      };
      extraOptions = ["--network=postgrest"];
    };
  };
}
