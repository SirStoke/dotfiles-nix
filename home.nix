{
  config,
  pkgs,
  unstablePkgs,
  ...
}: let
  lambda-gitster = pkgs.fetchgit {
    url = "https://github.com/ergenekonyigit/lambda-gitster.git";
    sparseCheckout = ["lambda-gitster.zsh-theme"];
    rev = "bc9cb4948920d9cbb72c3b78d18070d1cc94934b";
    sha256 = "sha256-LVfjKimekXz5Rbl4QJEcD4vQUkzrM2DoZ6iuFwCPhOc";
  };

  base16-shell = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "cd71822de1f9b53eea9beb9d94293985e9ad7122";
    sha256 = "sha256-mXCC7lT2KXySn5vSK8huLFYObWA0mD3jp/WQU6iM9Vo=";
  };
in {
  xdg.enable = true;

  nixpkgs.config.allowUnsupportedSystem = true;

  home.file.".zsh-custom/themes/lambda-gitster.zsh-theme".source = "${lambda-gitster}/lambda-gitster.zsh-theme";
  home.file.".base16_theme".source = "${base16-shell}/scripts/base16-ocean.sh";
  home.file.".ideavimrc".text = builtins.readFile ./home/.ideavimrc;
  home.file.".npmrc".text = "prefix=$${HOME}/.npm-packages";

  home.file."nvim" = {
    source = ./nvim;
    target = ".config/nvim";
    recursive = true;
  };

  home.packages = with pkgs; [
    ripgrep
    devbox
    jq
    tree
    scala-cli
    cachix
    luajitPackages.luarocks
    coursier
  ];

  home.stateVersion = "22.11";

  programs.neovim.enable = true;
  programs.neovim.vimAlias = true;
  programs.neovim.package = unstablePkgs.neovim-unwrapped.overrideAttrs (old: {
    meta =
      old.meta or {}
      // {
        maintainers = [];
      };
  });

  programs.zsh = {
    enable = true;
    initExtra =
      (builtins.readFile ./home/init.zsh)
      + ''
        BASE16_SHELL="${base16-shell}"
        [ -n "$PS1" ] && \
            [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
                eval "$("$BASE16_SHELL/profile_helper.sh")"

        export EDITOR=vim

        eval "$(direnv hook zsh)"
      '';
  };

  programs.alacritty.enable = false;

  programs.alacritty.settings = {
    font = {
      normal = {
        family = "SauceCodePro Nerd Font";
        style = "regular";
      };
      size = 10;
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank

      (mkTmuxPlugin {
        pluginName = "catppuccin";
        version = "0.1";
        src = pkgs.fetchFromGitHub {
          owner = "dreamsofcode-io";
          repo = "catppuccin-tmux";
          rev = "b4e0715356f820fc72ea8e8baf34f0f60e891718";
          sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
        };
      })
    ];

    extraConfig = ''
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Use Alt-arrow keys without prefix key to switch panes
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Shift arrow to switch windows
      bind -n S-Left  previous-window
      bind -n S-Right next-window

      set -g @catppuccin_flavour 'mocha'

      # set vi-mode
      set-window-option -g mode-keys vi

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind - split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"

      # Free C-l up to clear the screen
      unbind -n C-l
    '';

    prefix = "C-space";
  };

  programs.git = {
    enable = true;
    userEmail = "sandro.mosca.dev@gmail.com";
    userName = "SirStoke";

    signing.signByDefault = true;
    signing.key = "4A24C13FB5F4E06E";

    difftastic.enable = true;
    lfs.enable = true;

    extraConfig.url."https://github.com/rust-lang/crates.io-index".insteadOf = https://github.com/rust-lang/crates.io-index;
    extraConfig.credential."https://github.com".useHttpPath = true;
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = ["git" "node" "npm" "nvm" "scala" "sbt" "pip" "github" "vundle" "gpg-agent" "git-lfs" "iterm2" "macos" "sdk" "docker" "docker-compose" "rust" "aws"];
    custom = "$HOME/.zsh-custom";
    theme = "lambda-gitster";
  };

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;
  programs.zoxide.options = ["--cmd" "cd"];

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.direnv.enable = true;
}
