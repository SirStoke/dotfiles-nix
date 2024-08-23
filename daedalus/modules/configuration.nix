{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
        devices = ["nodev"];
        path = "/boot";
      }
    ];
  };

  # The key is stored raw in a disk partition, so this is an hack to load the partitions before ZFS initializes
  boot.zfs.devNodes = lib.mkForce "/dev/disk/by-partuuid";

  fileSystems."/boot" = {
    device = "/dev/sdd2";
    fsType = "vfat";
    options = ["noatime" "nofail" "umask=0077"]; # optional, additional options for mounting
  };

  fileSystems."/" = {
    device = "root/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "root/nix";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "root/var";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "root/home";
    fsType = "zfs";
  };

  fileSystems."/var/data" = {
    device = "data/data";
    fsType = "zfs";
  };

  services.zfs.autoScrub.enable = true;

  networking.hostId = "574b7de7";

  swapDevices = [];

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    clang
    unzip
  ];

  programs.zsh.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  users.users.sandro = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.zsh;
    hashedPassword = "$6$nlzgALREFEkm.Ldo$SK7SGTdlawCbe1DelOg8qxvBOXcdFLvU/xqUN/tNgsFtjO/EOmSKK5tFVt7ajTrwy2Vf.OlnWFc5S4Lsn4Ye0/";
  };

  virtualisation.containers.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.gnupg.agent.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "yes";

  networking.hostName = "daedalus";
  networking.networkmanager.enable = true;
  networking.nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4"];
  networking.firewall.checkReversePath = false;

  services.tailscale.enable = true;

  boot.extraModulePackages = [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
