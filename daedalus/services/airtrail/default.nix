{pkgs, ...}: let
  environmentFile = "/var/lib/airtrail/airtrail.env";
  networkService = "podman-airtrail-network.service";
  environmentService = "airtrail-environment.service";
in {
  systemd.services.podman-airtrail-network = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists airtrail || podman network create airtrail
    '';
  };

  systemd.services.airtrail-environment = {
    description = "Create the AirTrail container environment";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "airtrail";
      StateDirectoryMode = "0700";
      UMask = "0077";
    };
    script = ''
      if [[ ! -e ${environmentFile} ]]; then
        password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        temporary_file="$(${pkgs.coreutils}/bin/mktemp /var/lib/airtrail/airtrail.env.XXXXXX)"

        {
          echo "ORIGIN=https://airtrail.sirstoke.me"
          echo "DB_URL=postgres://airtrail:$password@airtrail-db:5432/airtrail"
          echo "DB_PASSWORD=$password"
          echo "POSTGRES_PASSWORD=$password"
          echo "DB_DATABASE_NAME=airtrail"
          echo "DB_USERNAME=airtrail"
          echo "POSTGRES_DB=airtrail"
          echo "POSTGRES_USER=airtrail"
          echo "UPLOAD_LOCATION=/app/uploads"
          echo "BODY_SIZE_LIMIT=20M"
        } > "$temporary_file"

        chmod 0600 "$temporary_file"
        mv "$temporary_file" ${environmentFile}
      fi

      chmod 0600 ${environmentFile}
    '';
  };

  systemd.services.podman-airtrail-db = {
    after = [
      environmentService
      networkService
    ];
    requires = [
      environmentService
      networkService
    ];
  };

  systemd.services.podman-airtrail = {
    after = [
      environmentService
      networkService
      "podman-airtrail-db.service"
    ];
    requires = [
      environmentService
      networkService
      "podman-airtrail-db.service"
    ];
    serviceConfig.ExecStartPre = pkgs.writeShellScript "wait-for-airtrail-db" ''
      for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
        if ${pkgs.podman}/bin/podman exec airtrail-db \
          pg_isready -U airtrail -d airtrail >/dev/null 2>&1; then
          exit 0
        fi
        ${pkgs.coreutils}/bin/sleep 2
      done

      echo "PostgreSQL did not become ready within 60 seconds" >&2
      exit 1
    '';
  };

  virtualisation.oci-containers.containers = {
    airtrail-db = {
      image = "postgres:16-alpine@sha256:7a396fd264a2067788b6551122b50f162bf6136312c7fc9d74381cb92c648382";
      volumes = ["airtrail-db:/var/lib/postgresql/data"];
      environmentFiles = [environmentFile];
      extraOptions = ["--network=airtrail"];
    };

    airtrail = {
      image = "johly/airtrail:v3.11.1@sha256:f1a0cfe4b44883b971083cf7f6c8e813730644219e0b21d7f4aefb51b8ca4702";
      ports = ["127.0.0.1:3002:3000"];
      volumes = ["airtrail-uploads:/app/uploads:U"];
      environmentFiles = [environmentFile];
      dependsOn = ["airtrail-db"];
      extraOptions = ["--network=airtrail"];
    };
  };
}
