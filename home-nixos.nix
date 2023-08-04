{
  config,
  pkgs,
  master-pkgs,
  recursiveUpdate,
  ...
}: let
  base = import ./home.nix {inherit config pkgs;};
in
  recursiveUpdate base {
    home.packages = base.home.packages ++ (with pkgs; [ 
      libsForQt5.bismuth 
      pinentry 
      (pkgs.ungoogled-chromium.override { commandLineArgs = [ "--force-dark-mode" ]; enableWideVine = true; })
      xclip
      terminator
      powerline-fonts
      signal-desktop
      spotify
      qbittorrent
      lutris
      jetbrains-mono
      syncthing
      vscode-fhs
      docker-compose
      obs-studio
      vlc
    ]) ++ (with master-pkgs; [ discord protonvpn-gui obsidian dropbox ]);

    programs.zsh.initExtra =
      base.programs.zsh.initExtra
      + ''
        alias nrs="sudo nixos-rebuild switch --flake '$HOME/src/dotfiles-nix#mjollnir'"
      '';

    home.file."/home/sandro/.config/terminator/config".text = builtins.readFile ./home/terminator-config;

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };

    fonts.fontconfig.enable = false;
    services.syncthing.enable = true;
  }
