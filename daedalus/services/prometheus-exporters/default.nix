{...}: {
  services.prometheus.exporters.systemd.enable = true;
  services.prometheus.exporters.zfs.enable = true;

#  virtualisation.oci-containers.containers = {
#    deluge-exporter = {
#      image = "tobbez/deluge_exporter:latest";
#
#      ports = ["127.0.0.1:9354:9354"];
#
#      environmentFiles = [
#        "/run/agenix/deluge-exporter-secrets"
#      ];
#    };
#  };
}
