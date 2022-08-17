{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  networking.hostName = "loki";

  time.timeZone = "Europe/Rome";

  users.mutableUsers = false;

  users.users.sandro = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$nlzgALREFEkm.Ldo$SK7SGTdlawCbe1DelOg8qxvBOXcdFLvU/xqUN/tNgsFtjO/EOmSKK5tFVt7ajTrwy2Vf.OlnWFc5S4Lsn4Ye0/";
  };

  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "us";
  };

  services.xserver.desktopManager.plasma5.enable = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim 
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

