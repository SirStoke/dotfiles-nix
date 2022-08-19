{ config, pkgs, recursiveUpdate, ... }: 
  let 
    base = import ./home.nix { inherit config pkgs; };
  in recursiveUpdate base {
    programs.home-manager.enable = true;

    programs.zsh.initExtra = base.programs.zsh.initExtra + ''

    '';
  }
