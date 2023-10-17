{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  users.users.root.initialHashedPassword = "$6$64JC3IgzLnlXjEm.$Ge4eBdHCioOV4otDyTn7pWYcbgo.r8x2kcktwBFh1L5Z.unObG5KYa4I4tXtOFQo3wca5Gi9CIQaqUMsM8S2M0";

  networking.hostName = "mjollnir";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Rome";

  services.plex.enable = true;
  services.plex.openFirewall = true;

  users.mutableUsers = false;

  users.users.sandro = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.zsh;
    hashedPassword = "$6$nlzgALREFEkm.Ldo$SK7SGTdlawCbe1DelOg8qxvBOXcdFLvU/xqUN/tNgsFtjO/EOmSKK5tFVt7ajTrwy2Vf.OlnWFc5S4Lsn4Ye0/";
  };

  users.users.sandro-gaming = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "docker"];
    shell = pkgs.zsh;
    hashedPassword = "$6$nlzgALREFEkm.Ldo$SK7SGTdlawCbe1DelOg8qxvBOXcdFLvU/xqUN/tNgsFtjO/EOmSKK5tFVt7ajTrwy2Vf.OlnWFc5S4Lsn4Ye0/";
  };

  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "us";
  };

  services.xserver.desktopManager.plasma5.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  services.xrdp.openFirewall = true;

  # Packages are mainly installed by home-manager, this is the strict necessary
  environment.systemPackages = with pkgs; [
    vim
  ];

  services.openssh.enable = true;
  services.openssh.passwordAuthentication = true;
  services.openssh.permitRootLogin = "yes";

  services.flatpak.enable = true;

  environment.shells = [pkgs.zsh];

  boot.extraModulePackages = [config.boot.kernelPackages.rtl88x2bu];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };

  programs.zsh.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.blueman.enable = true;

  fonts.fontconfig.enable = true;
  fonts.fontconfig.hinting.enable = false;

  fonts.fonts = with pkgs; [fira-code nerdfonts];

  virtualisation.docker.enable = true;

  nix.settings.trusted-users = ["root" "sandro"];

  hardware.enableAllFirmware = true;

  networking.firewall.allowedTCPPorts = [42000 42001];

  programs.partition-manager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
