{ config, pkgs, recursiveUpdate, ... }: 
  let 
    base = import ./home.nix { inherit config pkgs; };
  in recursiveUpdate base {
    imports = [ ./modules/homebrew.nix ];

    programs.home-manager.enable = true;

    home.packages = base.home.packages ++ (
      with pkgs; [ iterm2 ]
    );

    # Eventually, both sdkman and fnm will not be needed and everything will be managed by per-project nix flakes
    programs.zsh.initExtra = base.programs.zsh.initExtra + ''
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

      # fnm
      export PATH=/Users/sandro/.fnm:$PATH
      eval "`fnm env`"

      source ~/.zsh_work_env
    '';

    programs.zsh.shellAliases = {
      hm-switch = "cd ~/.config/nixpkgs && nix flake update && home-manager switch; cd -";
    };

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
