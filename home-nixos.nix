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
    home.packages =
      base.home.packages
      ++ (with pkgs; [
        libsForQt5.bismuth
        pinentry
        (pkgs.ungoogled-chromium.override {
          commandLineArgs = ["--force-dark-mode"];
          enableWideVine = true;
        })
        xclip
        terminator
        powerline-fonts
        signal-desktop
        spotify
        qbittorrent
        jetbrains-mono
        jetbrains.idea-community
        temurin-bin-21
        syncthing
        docker-compose
        obs-studio
        vlc
        gh
        devbox
        libreoffice-qt
        discord
        protonvpn-gui
        obsidian
        dropbox
        vscode-fhs
        flyctl
        clang
        stylua
        unzip
        nodePackages.typescript-language-server
        steamtinkerlaunch
      ])
      ++ (with unstablePkgs; [code-cursor])
      ++ (with nix-alien-pkgs; [nix-alien]);

    programs.zsh.initExtra =
      base.programs.zsh.initExtra
      + ''
        alias nrs="sudo nixos-rebuild switch --flake '$HOME/src/dotfiles-nix#mjollnir'"
      '';

    home.file."/home/sandro/.config/terminator/config".text = builtins.readFile ./home/terminator-config;

    programs.gpg.enable = true;

    services.gpg-agent = {
      pinentryPackage = pkgs.pinentry-qt;
      enable = true;

      # cache the keys forever so we don't get asked for a password
      defaultCacheTtl = 31536000;
      maxCacheTtl = 31536000;
    };

    programs.kitty.enable = true;
    programs.kitty.font.name = "SauceCodePro Nerd Font";
    programs.kitty.font.size = 10;

    fonts.fontconfig.enable = false;
    services.syncthing.enable = true;

    programs.alacritty.enable = true;
    programs.firefox.enable = true;
    programs.firefox.profiles.default.path = "961vbxr5.default-1708189349057";
    programs.firefox.profiles.default.userChrome = ''
      /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/hide_tabs_toolbar.css made available under Mozilla Public License v. 2.0
      See the above repository for updates as well as full license text. */

      /* Hides tabs toolbar */
      /* For OSX use hide_tabs_toolbar_osx.css instead */

      /* Note, if you have either native titlebar or menubar enabled, then you don't really need this style.
       * In those cases you can just use: #TabsToolbar{ visibility: collapse !important }
       */

      /* IMPORTANT */
      /*
      Get window_control_placeholder_support.css
      Window controls will be all wrong without it
      */
      #TabsToolbar{ visibility: collapse !important }

      :root[tabsintitlebar]{ --uc-toolbar-height: 40px; }
      :root[tabsintitlebar][uidensity="compact"]{ --uc-toolbar-height: 32px }
      #titlebar{
        will-change: unset !important;
        transition: none !important;
        opacity: 1 !important;
      }
      #TabsToolbar{ visibility: collapse !important }

      :root[sizemode="fullscreen"] #TabsToolbar > :is(#window-controls,.titlebar-buttonbox-container){
        visibility: visible !important;
        z-index: 2;
      }

      :root:not([inFullscreen]) #nav-bar{
        margin-top: calc(0px - var(--uc-toolbar-height,0px));
      }

      :root[tabsintitlebar] #toolbar-menubar[autohide="true"]{
        min-height: unset !important;
        height: var(--uc-toolbar-height,0px) !important;
        position: relative;
      }

      #toolbar-menubar[autohide="false"]{
        margin-bottom: var(--uc-toolbar-height,0px)
      }

      :root[tabsintitlebar] #toolbar-menubar[autohide="true"] #main-menubar{
        flex-grow: 1;
        align-items: stretch;
        background-attachment: scroll, fixed, fixed;
        background-position: 0 0, var(--lwt-background-alignment), right top;
        background-repeat: repeat-x, var(--lwt-background-tiling), no-repeat;
        background-size: auto 100%, var(--lwt-background-size, auto auto), auto auto;
        padding-right: 20px;
      }
      :root[tabsintitlebar] #toolbar-menubar[autohide="true"]:not([inactive]) #main-menubar{
        background-color: var(--lwt-accent-color);
        background-image: linear-gradient(var(--toolbar-bgcolor,--toolbar-non-lwt-bgcolor),var(--toolbar-bgcolor,--toolbar-non-lwt-bgcolor)), var(--lwt-additional-images,none), var(--lwt-header-image, none);
        mask-image: linear-gradient(to left, transparent, black 20px);
      }

       #toolbar-menubar:not([inactive]){ z-index: 2 }
       #toolbar-menubar[autohide="true"][inactive] > #menubar-items {
        opacity: 0;
        pointer-events: none;
        margin-left: var(--uc-window-drag-space-pre,0px)
      }
    '';
  }
