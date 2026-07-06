{...}: {
  virtualisation.oci-containers.containers = {
    hermes-agent = {
      image = "docker.io/nousresearch/hermes-agent:latest";
      ports = [
        "8642:8642"
        "9119:9119"
      ];
      volumes = ["/var/data/hermes:/opt/data"];
      environment = {
        HERMES_UID = "1000";
        HERMES_GID = "1000";
        HERMES_DASHBOARD = "1";
      };
      cmd = ["gateway" "run"];
    };
  };
}
