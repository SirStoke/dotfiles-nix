{
  virtualisation.oci-containers = {
    backend = "docker";

    containers.moonlight-web-stream = {
      image = "mrcreativ3001/moonlight-web-stream:v2.10.0@sha256:4ee561ec4043526e93b0b3dba4926031c86ee3c9dab0333475a6b3c7117c701a";
      autoStart = true;
      environment.WEBRTC_PORT_RANGE = "40000:40100";
      volumes = ["moonlight-web-stream:/moonlight-web/server"];
      extraOptions = ["--network=host"];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [8080];
    allowedUDPPortRanges = [
      {
        from = 40000;
        to = 40100;
      }
    ];
  };
}
