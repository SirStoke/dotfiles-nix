{
  config,
  pkgs,
  unstablePkgs,
  recursiveUpdate,
  nix-alien-pkgs,
  ...
}: let
  base = import ./home.nix {inherit config pkgs unstablePkgs;};
in
  recursiveUpdate base {
    home.username = "sandro";
    home.homeDirectory = "/home/sandro";

    home.packages =
      base.home.packages
      ++ (with pkgs; [
        libsForQt5.bismuth
        pinentry
        xclip
        signal-desktop
        jetbrains.idea-community
        clang
        stylua
        unzip
        nodePackages.typescript-language-server
        appimage-run
      ])
      ++ (with unstablePkgs; [qbittorrent vscode-fhs]);

    programs.zsh.initExtra = base.programs.zsh.initExtra;

    home.file."/home/sandro/.config/terminator/config".text = builtins.readFile ./home/terminator-config;

    home.shellAliases = {
      hm-switch = "cd $HOME/src/dotfiles-nix && nix run home-manager/release-25.05 -- switch --flake .#sandro-linux && cd -";
    };

    programs.gpg.enable = true;

    services.gpg-agent = {
      pinentryPackage = pkgs.pinentry-qt;
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };

    fonts.fontconfig.enable = false;

    programs.firefox.enable = true;
  }
