{...}: {
  virtualisation.oci-containers.containers = {
    mealie = {
      image = "ghcr.io/mealie-recipes/mealie:v1.12.0";
      volumes = ["/var/data/mealie:/app/data"];
      ports = ["127.0.0.1:9000:9000"];
      environment = {
        BASE_URL = "https://mealie.sirstoke.me";
        PRODUCTION = "true";
      };
    };
  };
}
