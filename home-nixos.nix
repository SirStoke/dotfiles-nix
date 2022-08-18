{ config, pkgs, ... }:

let
  base = import ./home.nix { config pkgs };
in
  base // {
    home.packages = base.packages ++ [ pkgs.libsForQt5.bismuth pkgs.pinentry ];

    programs.git = {
      enable = true;
      userEmail = "sandro.mosca.dev@gmail.com";
      userName = "SirStoke";

      signing.signByDefault = true;
      signing.key = "4A24C13FB5F4E06E";
    };

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };
  }
