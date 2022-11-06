{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./zfs.nix
    ./hardware-configuration.nix
    ./noisetorch.nix
  ];
}
