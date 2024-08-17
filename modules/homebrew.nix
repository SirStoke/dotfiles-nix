# An home-manager module that manages brew packages, forked from nix-darwin's
# Originally created by: https://github.com/malob
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.homebrew;

  brewfileSection = heading: type: entries:
    optionalString (entries != [])
    "# ${heading}\n"
    + (concatMapStrings (name: "${type} \"${name}\"\n") entries)
    + "\n";

  masBrewfileSection = entries:
    optionalString (entries != {}) (
      "# Mac App Store apps\n"
      + concatStringsSep "\n" (mapAttrsToList (name: id: ''mas "${name}", id: ${toString id}'') entries)
      + "\n"
    );

  brewfile = pkgs.writeText "Brewfile" (
    brewfileSection "Taps" "tap" cfg.taps
    + brewfileSection "Brews" "brew" cfg.brews
    + brewfileSection "Casks" "cask" cfg.casks
    + masBrewfileSection cfg.masApps
    + brewfileSection "Docker containers" "whalebrew" cfg.whalebrews
    + optionalString (cfg.extraConfig != "") ("# Extra config\n" + cfg.extraConfig)
  );

  brew-bundle-command = concatStringsSep " " (
    optional (!cfg.autoUpdate) "HOMEBREW_NO_AUTO_UPDATE=1 $DRY_RUN_CMD"
    ++ ["brew bundle --file='${brewfile}' --no-lock"]
    ++ optional (cfg.cleanup == "uninstall" || cfg.cleanup == "zap") "--cleanup"
    ++ optional (cfg.cleanup == "zap") "--zap"
  );
in {
  options.homebrew = {
    enable = mkEnableOption ''
      configuring your Brewfile, and installing/updating the formulas therein via
      the <command>brew bundle</command> command, using <command>nix-darwin</command>.

      Note that enabling this option does not install Homebrew. See the Homebrew website for
      installation instructions: https://brew.sh
    '';

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = ''
        When enabled, Homebrew is allowed to auto-update during <command>nix-darwin</command>
        activation. The default is <literal>false</literal> so that repeated invocations of
        <command>darwin-rebuild switch</command> are idempotent.
      '';
    };

    brewPrefix = mkOption {
      type = types.str;
      default = "/opt/homebrew/bin";
      description = ''
        Customize path prefix where executable of <command>brew</command> is searched for.
      '';
    };

    cleanup = mkOption {
      type = types.enum ["none" "uninstall" "zap"];
      default = "none";
      example = "uninstall";
      description = ''
        This option manages what happens to formulas installed by Homebrew, that aren't present in
        the Brewfile generated by this module.

        When set to <literal>"none"</literal> (the default), formulas not present in the generated
        Brewfile are left installed.

        When set to <literal>"uninstall"</literal>, <command>nix-darwin</command> invokes
        <command>brew bundle [install]</command> with the <command>--cleanup</command> flag. This
        uninstalls all formulas not listed in generate Brewfile, i.e.,
        <command>brew uninstall</command> is run for those formulas.

        When set to <literal>"zap"</literal>, <command>nix-darwin</command> invokes
        <command>brew bundle [install]</command> with the <command>--cleanup --zap</command>
        flags. This uninstalls all formulas not listed in the generated Brewfile, and if the
        formula is a cask, removes all files associated with that cask. In other words,
        <command>brew uninstall --zap</command> is run for all those formulas.

        If you plan on exclusively using <command>nix-darwin</command> to manage formulas installed
        by Homebrew, you probably want to set this option to <literal>"uninstall"</literal> or
        <literal>"zap"</literal>.
      '';
    };

    taps = mkOption {
      type = with types; listOf str;
      default = [];
      example = ["homebrew/cask-fonts"];
      description = "Homebrew formula repositories to tap.";
    };

    brews = mkOption {
      type = with types; listOf str;
      default = [];
      example = ["mas"];
      description = "Homebrew brews to install.";
    };

    casks = mkOption {
      type = with types; listOf str;
      default = [];
      example = ["hammerspoon" "virtualbox"];
      description = "Homebrew casks to install.";
    };

    masApps = mkOption {
      type = with types; attrsOf ints.positive;
      default = {};
      example = {
        "1Password" = 1107421413;
        Xcode = 497799835;
      };
      description = ''
        Applications to install from Mac App Store using <command>mas</command>.

        When this option is used, <literal>"mas"</literal> is automatically added to
        <option>homebrew.brews</option>.

        Note that you need to be signed into the Mac App Store for <command>mas</command> to
        successfully install and upgrade applications, and that unfortunately apps removed from this
        option will not be uninstalled automatically even if
        <option>homebrew.cleanup</option> is set to <literal>"uninstall"</literal>
        or <literal>"zap"</literal> (this is currently a limitation of Homebrew Bundle).

        For more information on <command>mas</command> see: https://github.com/mas-cli/mas.
      '';
    };

    whalebrews = mkOption {
      type = with types; listOf str;
      default = [];
      example = ["whalebrew/wget"];
      description = ''
        Docker images to install using <command>whalebrew</command>.

        When this option is used, <literal>"whalebrew"</literal> is automatically added to
        <option>homebrew.brews</option>.

        For more information on <command>whalebrew</command> see:
        https://github.com/whalebrew/whalebrew.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        # 'brew tap' with custom Git URL
        tap "user/tap-repo", "https://user@bitbucket.org/user/homebrew-tap-repo.git"

        # set arguments for all 'brew cask install' commands
        cask_args appdir: "~/Applications", require_sha: true

        # 'brew install --with-rmtp', 'brew services restart' on version changes
        brew "denji/nginx/nginx-full", args: ["with-rmtp"], restart_service: :changed
        # 'brew install', always 'brew services restart', 'brew link', 'brew unlink mysql' (if it is installed)
        brew "mysql@5.6", restart_service: true, link: true, conflicts_with: ["mysql"]

        # 'brew cask install --appdir=~/my-apps/Applications'
        cask "firefox", args: { appdir: "~/my-apps/Applications" }
        # 'brew cask install' only if '/usr/libexec/java_home --failfast' fails
        cask "java" unless system "/usr/libexec/java_home --failfast"
      '';
      description = "Extra lines to be added verbatim to the generated Brewfile.";
    };
  };

  config = {
    homebrew.brews =
      optional (cfg.masApps != {}) "mas"
      ++ optional (cfg.whalebrews != []) "whalebrew";

    home.activation.homebrew = mkIf cfg.enable (hm.dag.entryAfter ["writeBoundary"] ''
      # Homebrew Bundle
      echo >&2 "Homebrew bundle..."
      if [ -f "${cfg.brewPrefix}/brew" ]; then
        PATH="${cfg.brewPrefix}":$PATH ${brew-bundle-command}
      else
        echo -e "\e[1;31merror: Homebrew is not installed, skipping...\e[0m" >&2
      fi
    '');
  };
}
