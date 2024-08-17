{
  config,
  pkgs,
  ...
}: {
  services.bazarr = {
    enable = true;
  };
}
