{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./vmware-guest.nix
    ./zfs.nix
    ./hardware-configuration.nix
  ];

  # Disable the default vmware-guest, we'll use our own which works on aarch64
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  virtualisation.vmware.guest.enable = true;
}
