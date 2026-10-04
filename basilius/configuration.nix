{lib,pkgs, ...}: let
  mobileNixos = /etc/nixos/mobile-nixos;
  pinnedNixpkgs = (import (mobileNixos + "/npins")).nixpkgs;
in {
  imports = [./services];

  #  imports = [
  #    (import (mobileNixos + "/lib/configuration.nix") {
  #      device = "oneplus-enchilada";
  #    })
  #  ];

  networking = {
    hostName = "basilius";
    networkmanager = {
      enable = true;
      unmanaged = ["rndis0" "usb0"];
    };
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];

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

  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [wget clang unzip];

  time.timeZone = "Europe/Madrid";

  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.tailscale = {
    enable = true;
  };

  users.users.sandro = {
    isNormalUser = true;
    # Remove 'isSystemUser = true;' if it is present here
    extraGroups = ["wheel" "networkmanager"]; # Add your desired groups
    shell = pkgs.zsh;
  };

  users.users.sandro.group = "sandro";

  users.groups.sandro = {};

  users.groups.media = {
    members = ["sandro"];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  #  # Make subsequent nixos-rebuild invocations use this Mobile NixOS checkout
  #  # and the Nixpkgs revision pinned by it.
  #  nix.nixPath = [
  #    "nixpkgs=${pinnedNixpkgs}"
  #    "mobile-nixos=${mobileNixos}"
  #    "nixos-config=/etc/nixos/configuration.nix"
  #  ];

  system.stateVersion = "26.11";
}
