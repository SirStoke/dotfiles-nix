{ config, pkgs, ... }:

let
  base = import ./home.nix { inherit config pkgs; };
in
  pkgs.lib.recursiveUpdate base {
    home.packages = base.home.packages ++ [ pkgs.libsForQt5.bismuth pkgs.pinentry pkgs.ungoogled-chromium ];

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };
  }
