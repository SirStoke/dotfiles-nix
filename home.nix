{ config, pkgs, ... }:

let
  lambda-gitster = pkgs.fetchgit {
    url = "https://github.com/ergenekonyigit/lambda-gitster.git";
    sparseCheckout = "lambda-gitster.zsh-theme";
    rev = "bc9cb4948920d9cbb72c3b78d18070d1cc94934b";
    sha256 = "sha256-LVfjKimekXz5Rbl4QJEcD4vQUkzrM2DoZ6iuFwCPhOc";
  };

  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "cd71822de1f9b53eea9beb9d94293985e9ad7122";
    sha256 = "sha256-mXCC7lT2KXySn5vSK8huLFYObWA0mD3jp/WQU6iM9Vo=";
  };
in
{
  xdg.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  home.file.".zsh-custom/themes/lambda-gitster.zsh-theme".source = "${lambda-gitster}/lambda-gitster.zsh-theme";
  home.file.".base16_theme".source = "${base16-shell}/scripts/base16-ocean.sh";
  home.file.".ideavimrc".text = builtins.readFile ./home/.ideavimrc;

  home.packages = [
    pkgs.fzf
    pkgs.ripgrep
    pkgs.jq
    pkgs.tree
    pkgs.zoxide
  ];

  home.stateVersion = "22.11";

  programs.neovim.enable = true;
  programs.neovim.vimAlias = true;

  programs.neovim.plugins = with pkgs.vimPlugins; [
    nerdtree
    base16-vim
    vim-airline
    vim-airline-themes
    ctrlp-vim
    vim-scala
    vim-sleuth
    vim-fugitive
    tabular
    vim-javascript
    vim-jsx-pretty
    onedark-nvim
    fzf-vim
    vim-nix
  ];
  
  programs.neovim.extraConfig = builtins.readFile ./home/init.vim;

  programs.zsh = {
    enable = true;
    initExtra = (builtins.readFile ./home/init.zsh) + ''
      BASE16_SHELL="${base16-shell}"
      [ -n "$PS1" ] && \
          [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
              eval "$("$BASE16_SHELL/profile_helper.sh")"

      export EDITOR=vim
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "sandro.mosca.dev@gmail.com";
    userName = "SirStoke";

    signing.signByDefault = true;
    signing.key = "4A24C13FB5F4E06E";

    difftastic.enable = true;
    lfs.enable = true;

    extraConfig.url."git@github.com:".insteadOf = https://github.com/;
    extraConfig.url."https://github.com/rust-lang/crates.io-index".insteadOf = https://github.com/rust-lang/crates.io-index;
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" "node" "npm" "nvm" "scala" "sbt" "pip" "github" "vundle" "gpg-agent" "git-lfs" "iterm2" "macos" "sdk" "docker" "docker-compose" "rust" "aws" ];
    custom = "$HOME/.zsh-custom";
    theme = "lambda-gitster";
  };
}
