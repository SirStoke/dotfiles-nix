{ config, pkgs, recursiveUpdate, ... }: 
  let 
    base = import ./home.nix { inherit config pkgs; };

    raycastLayout = name: let
      escaped = builtins.replaceStrings [" "] ["%20"] name;
    in
      {
        text = ''
          #!/bin/bash

          # Required parameters:
          # @raycast.schemaVersion 1
          # @raycast.title Switch to ${name} layout
          # @raycast.mode silent

          # Optional parameters:
          # @raycast.icon 🤖

          open -g "rectangle-pro://execute-layout?name=${escaped}"
        ''; 

        executable = true;
      };

    raycastLayoutScript = name: "Documents/" + pkgs.lib.strings.toLower (builtins.replaceStrings [" "] ["-"] name) + ".sh";

    layouts = 
      pkgs.lib.lists.foldr 
        (a: b: b // { ${raycastLayoutScript a} = raycastLayout a; })
        {}
        [ "Personal Chores" "Daily Bot" "Daily" "Coding" "Coding Laptop" "Meeting" ];
  in recursiveUpdate base {
    home.homeDirectory = "/users/Sandro";
    home.username = "sandro";
    home.stateVersion = "22.11";

    xdg.enable = false;

    imports = [ ./modules/homebrew.nix ];

    home.packages = base.home.packages ++ (
      with pkgs; [ iterm2 postgresql ]
    );
    
    programs.home-manager.enable = true;

    # Eventually, fnm will not be needed and everything will be managed by per-project nix flakes
    programs.zsh.initExtra = base.programs.zsh.initExtra + ''
      # fnm
      export PATH=/Users/sandro/.fnm:$PATH
      eval "`fnm env`"

      source ~/.zsh_work_env
    '';

    home.file = base.home.file // layouts;

    programs.git = base.programs.git // {
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
