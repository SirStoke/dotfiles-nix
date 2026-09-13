{ lib, ... }:

let
  mobileNixos = /etc/nixos/mobile-nixos;
  pinnedNixpkgs = (import (mobileNixos + "/npins")).nixpkgs;
in
{
  imports = [
    (import (mobileNixos + "/lib/configuration.nix") {
      device = "oneplus-enchilada";
    })
  ];

  networking = {
    hostName = "basilius";
    networkmanager = {
      enable = true;
      unmanaged = [ "rndis0" "usb0" ];
    };
  };

  # Keep remote access available after switching to this configuration.
  mobile.adbd.enable = true;

  # Help avoid out-of-memory failures on a mobile device.
  zramSwap.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = lib.mkForce false;
  };

  environment.systemPackages = [ ];

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale = {
    enable = true;
  };

  # Make subsequent nixos-rebuild invocations use this Mobile NixOS checkout
  # and the Nixpkgs revision pinned by it.
  nix.nixPath = [
    "nixpkgs=${pinnedNixpkgs}"
    "mobile-nixos=${mobileNixos}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  system.stateVersion = "26.11";
}

