{ config, pkgs, recursiveUpdate, ... }: 
  let 
    base = import ./home.nix { inherit config pkgs; };
  in recursiveUpdate base {
    programs.home-manager.enable = true;

    # Eventually, both sdkman and fnm will not be needed and everything will be managed by per-project nix flakes
    programs.zsh.initExtra = base.programs.zsh.initExtra + ''
      export SDKMAN_DIR="$HOME/.sdkman"
      [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

      # fnm
      export PATH=/Users/sandro/.fnm:$PATH
      eval "`fnm env`"
    '';
  }
