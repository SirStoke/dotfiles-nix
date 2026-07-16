{pkgs, ...}: {
  virtualisation.oci-containers.containers.unmanic = {
    image = "josh5/unmanic@sha256:db7aa486154b918a8a6303bf08bc20de2a4a001e95f580df6721cc5c8f01ec58";
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
