{pkgs, ...}: {
  virtualisation.oci-containers.containers.unmanic = {
    image = "josh5/unmanic@sha256:3751881e8129e412c64453e6d11ff3fb1469121eeb271c73ad63f925a9f5c910";
    ports = ["127.0.0.1:8888:8888"];
    volumes = [
      "/var/data/unmanic:/config"
      "/var/data/media:/library"
      "/var/data/unmanic-cache:/tmp/unmanic"
    ];
    extraOptions = ["--device=/dev/dri"];
  };

  # Fail activation if the image ever stops shipping a working ffmpeg binary.
  systemd.services.podman-unmanic.serviceConfig.ExecStartPost = [
    "${pkgs.podman}/bin/podman exec unmanic ffmpeg -version"
  ];
}
