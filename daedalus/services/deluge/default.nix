{
  config,
  pkgs,
  ...
}: {
  services.deluge = {
    enable = true;
    web.enable = true;

    dataDir = "/var/data/deluge";
    group = "media";
  };
}
