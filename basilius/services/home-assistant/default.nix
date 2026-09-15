{lib, ...}: {
  networking.firewall.allowedTCPPorts = [8123];

  systemd.tmpfiles.rules = [
    "d /var/data/home-assistant/config 0755 root root -"
    "d /var/data/home-assistant/data 0755 root root -"
  ];

  systemd.services = {
    podman-homeassistant.serviceConfig = {
      Restart = lib.mkForce "always";
      TimeoutStartSec = lib.mkForce 900;
    };

    podman-matterjs-server = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig.Restart = lib.mkForce "always";
    };
  };

  virtualisation.oci-containers.containers = {
    homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = ["8123:8123"];
      volumes = [
        "/var/data/home-assistant/config:/config"
        "/etc/localtime:/etc/localtime:ro"
        "/run/dbus:/run/dbus:ro"
      ];
      environment.TZ = "Europe/Amsterdam";
      extraOptions = ["--privileged"];
      autoStart = true;
    };

    matterjs-server = {
      image = "ghcr.io/matter-js/matterjs-server:stable";
      volumes = ["/var/data/home-assistant/data:/data:U"];
      extraOptions = ["--network=host"];
      autoStart = true;
    };
  };
}
