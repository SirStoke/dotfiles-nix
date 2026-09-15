{pkgs, ...}: let
  stateDirectory = "/var/data/kimai";
  environmentFile = "${stateDirectory}/kimai.env";
  adminPasswordFile = "${stateDirectory}/admin-password";
  networkService = "podman-kimai-network.service";
  environmentService = "kimai-environment.service";
in {
  systemd.tmpfiles.rules = [
    "d ${stateDirectory} 0750 root media -"
    "d ${stateDirectory}/mysql 0750 root root -"
    "d ${stateDirectory}/data 0750 root root -"
    "d ${stateDirectory}/plugins 0750 root root -"
  ];

  systemd.services.podman-kimai-network = {
    path = [pkgs.podman];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman network exists kimai || podman network create kimai
    '';
  };

  systemd.services.kimai-environment = {
    description = "Create the Kimai container environment";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Group = "media";
      UMask = "0077";
    };
    script = ''
      if [[ ! -e ${environmentFile} ]]; then
        database_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        root_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        app_secret="$(${pkgs.openssl}/bin/openssl rand -hex 64)"
        admin_password="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
        environment_temporary="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/kimai.env.XXXXXX)"
        admin_temporary="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/admin-password.XXXXXX)"

        cleanup() {
          rm -f "$environment_temporary" "$admin_temporary"
        }
        trap cleanup EXIT

        {
          echo "MYSQL_DATABASE=kimai"
          echo "MYSQL_USER=kimaiuser"
          echo "MYSQL_PASSWORD=$database_password"
          echo "MYSQL_ROOT_PASSWORD=$root_password"
          echo "DATABASE_URL=mysql://kimaiuser:$database_password@kimai-db:3306/kimai?charset=utf8mb4&serverVersion=8.3.0"
          echo "APP_SECRET=$app_secret"
          echo "TRUSTED_HOSTS=kimai.sirstoke.me"
          echo "ADMINMAIL=sandro.mosca.dev@gmail.com"
          echo "ADMINPASS=$admin_password"
        } >"$environment_temporary"
        printf '%s\n' "$admin_password" >"$admin_temporary"

        chmod 0600 "$environment_temporary"
        chown root:media "$admin_temporary"
        chmod 0640 "$admin_temporary"
        mv "$admin_temporary" ${adminPasswordFile}
        mv "$environment_temporary" ${environmentFile}
        trap - EXIT
      fi

      if [[ ! -e ${adminPasswordFile} ]]; then
        admin_password="$(${pkgs.gnused}/bin/sed -n 's/^ADMINPASS=//p' ${environmentFile})"
        admin_temporary="$(${pkgs.coreutils}/bin/mktemp ${stateDirectory}/admin-password.XXXXXX)"
        printf '%s\n' "$admin_password" >"$admin_temporary"
        chown root:media "$admin_temporary"
        chmod 0640 "$admin_temporary"
        mv "$admin_temporary" ${adminPasswordFile}
      fi

      chown root:root ${environmentFile}
      chmod 0600 ${environmentFile}
      chown root:media ${adminPasswordFile}
      chmod 0640 ${adminPasswordFile}
    '';
  };

  systemd.services.podman-kimai-db = {
    after = [
      environmentService
      networkService
    ];
    requires = [
      environmentService
      networkService
    ];
  };

  systemd.services.podman-kimai = {
    after = [
      environmentService
      networkService
      "podman-kimai-db.service"
    ];
    requires = [
      environmentService
      networkService
      "podman-kimai-db.service"
    ];
    serviceConfig.ExecStartPre = pkgs.writeShellScript "wait-for-kimai-db" ''
      for attempt in $(${pkgs.coreutils}/bin/seq 1 30); do
        if ${pkgs.podman}/bin/podman exec kimai-db sh -c \
          'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqladmin ping --host=127.0.0.1 --user=root --silent' \
          >/dev/null 2>&1; then
          exit 0
        fi
        ${pkgs.coreutils}/bin/sleep 2
      done

      echo "MySQL did not become ready within 60 seconds" >&2
      exit 1
    '';
  };

  virtualisation.oci-containers.containers = {
    kimai-db = {
      image = "mysql:8.3@sha256:9de9d54fecee6253130e65154b930978b1fcc336bcc86dfd06e89b72a2588ebe";
      volumes = ["${stateDirectory}/mysql:/var/lib/mysql:U"];
      environmentFiles = [environmentFile];
      cmd = ["--default-storage-engine=InnoDB"];
      extraOptions = ["--network=kimai"];
    };

    kimai = {
      image = "kimai/kimai2:stable@sha256:3084f1e5ecdc10afafc193911039a06cdabda4473f3a48d62edbe460e3c154ee";
      ports = ["127.0.0.1:8001:8001"];
      volumes = [
        "${stateDirectory}/data:/opt/kimai/var/data:U"
        "${stateDirectory}/plugins:/opt/kimai/var/plugins:U"
      ];
      environmentFiles = [environmentFile];
      dependsOn = ["kimai-db"];
      extraOptions = ["--network=kimai"];
    };
  };
}
