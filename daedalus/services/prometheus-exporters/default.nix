{...}: {
  services.prometheus.exporters.systemd.enable = true;
  services.prometheus.exporters.zfs.enable = true;

  virtualisation.oci-containers.containers = {
    deluge-exporter = {
      image = "tobbez/deluge_exporter:latest";

      ports = ["127.0.0.1:9354:9354"];

      environmentFiles = [
        "/run/agenix/deluge-exporter-secrets"
      ];
    };
  };

  users.users.systemd-exporter = {
    isSystemUser = true;
    group = "systemd-exporter";
  };

  users.groups.systemd-exporter = {};

  # Can't read from dbus-daemon otherwise
  systemd.services."prometheus-systemd-exporter".serviceConfig.DynamicUser = false;
}
