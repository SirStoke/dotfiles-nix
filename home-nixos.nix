{ config, pkgs, master-pkgs, recursiveUpdate, ... }:

let
  base = import ./home.nix { inherit config pkgs; };
in
  recursiveUpdate base {
    home.packages = base.home.packages ++ (with pkgs; [ 
      libsForQt5.bismuth 
      pinentry 
      ungoogled-chromium 
      xclip
      terminator
      powerline-fonts
      signal-desktop
      spotify
      qbittorrent
      lutris
      jetbrains-mono
    ]) ++ (with master-pkgs; [ discord protonvpn-gui ]);

    programs.zsh.initExtra = base.programs.zsh.initExtra + ''
      alias nrs="sudo nixos-rebuild switch --flake '$HOME/src/dotfiles-nix#mjollnir'"
    '';

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };
  }
