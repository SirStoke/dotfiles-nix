{
  config,
  pkgs,
  recursiveUpdate,
  ...
}: let
  base = import ./home.nix {inherit config pkgs;};
in
  recursiveUpdate base {
    home.homeDirectory = "/users/Sandro";
    home.username = "sandro";
    home.stateVersion = "22.11";

    xdg.enable = false;

    imports = [./modules/homebrew.nix];

    home.packages =
      base.home.packages
      ++ (
        with pkgs; [
          iterm2
          postgresql
          jetbrains.gateway
          jetbrains.idea-ultimate
          vscode
          powerline-fonts
        ]
      );

    programs.home-manager.enable = true;

    # Eventually, fnm will not be needed and everything will be managed by per-project nix flakes
    programs.zsh.initExtra =
      base.programs.zsh.initExtra
      + ''
        # fnm
        export PATH=/Users/sandro/.fnm:$PATH
        eval "`fnm env`"

        source ~/.zsh_work_env
      '';

    programs.git =
      base.programs.git
      // {
        includes = [
          {
            condition = "gitdir:~/src/work/";
            path = "~/.gitconfig-work";
          }
        ];
      };

    programs.zsh.shellAliases = {
      hm-switch = "cd ~/src/dotfiles-nix && nix flake update && home-manager switch --flake .#sandro-darwin; cd -";
    };

    programs.gpg.enable = true;

    homebrew = {
      enable = true;

      brews = [
        "bitwarden-cli"
        "git-machete"
        "vault"
        "fnm"
        "brotli"
        "aria2"
      ];

      casks = [
        "amethyst"
        "eloston-chromium"
        "wkhtmltopdf"
      ];
    };
  }
