{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ./duplicity.nix
  ];
}
