{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-26.05;
  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-26.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.mobile-nixos-nixpkgs = {
    url = "github:mobile-nixos/mobile-nixos/development";
    flake = false;
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nix-alien.url = "github:thiagokokada/nix-alien/master";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    flake-utils,
    nix-alien,
    disko,
    agenix,
    mobile-nixos-nixpkgs,
    ...
  } @ attrs:
    rec {
      nixosConfigurations.mjollnir = let
        system = "x86_64-linux";

        unstablePkgs = import nixpkgs-unstable {
          inherit system;

          config.allowUnfree = true;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = attrs;
          modules = [
            ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sandro = import ./home-nixos.nix;
              home-manager.users.sandro-gaming = import ./home-nixos.nix;
              home-manager.extraSpecialArgs = {
                nix-alien-pkgs = nix-alien.packages.${system};
                recursiveUpdate = nixpkgs.lib.recursiveUpdate;
                unstablePkgs = unstablePkgs;
              };
            }
          ];
        };

      nixosConfigurations.basilius = let
        system = "aarch64-linux";

        npins = import "${mobile-nixos-nixpkgs}/npins";
        npins-pkgs = npins.nixpkgs;

        mobile-pkgs = import npins-pkgs {
          inherit system;

          config.allowUnfree = true;
        };

        # Setup our own version of nixos.lib.nixosSystem, as the
        # mobile-nixos input is not actually a flake.
        nixosSystem = args:
          import "${npins-pkgs}/nixos/lib/eval-config.nix" (
            {
              lib = import "${npins-pkgs}/lib";
              system = null;

              modules =
                args.modules
                ++ [
                  {
                    nixpkgs.flake.source = npins-pkgs;
                  }
                ];
            }
            // builtins.removeAttrs args ["modules"]
          );

        mobile-nixos = import "${mobile-nixos-nixpkgs}/lib/configuration.nix";
      in
        nixosSystem {
          inherit system;

          modules = [
            (mobile-nixos {device = "oneplus-enchilada";})
            # fix for the gt compilation failures
            {
              nixpkgs.overlays = [
                (final: prev: {
                  gadget-tool = prev.gadget-tool.overrideAttrs (old: {
                    postPatch =
                      (old.postPatch or "")
                      + ''
                        substituteInPlace CMakeLists.txt \
                          --replace-fail \
                            "cmake_minimum_required(VERSION 2.8)" \
                            "cmake_minimum_required(VERSION 3.10)"
                      '';
                  });
                })
              ];
     
              nixpkgs.config.allowUnfree = true;
            }
            ./basilius/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sandro = import ./home.nix;
              home-manager.extraSpecialArgs = {
                recursiveUpdate = mobile-pkgs.lib.recursiveUpdate;
                unstablePkgs = mobile-pkgs;
              };
            }
          ];
        };

      nixosConfigurations.daedalus = let
        system = "x86_64-linux";

        unstablePkgs = import nixpkgs-unstable {
          inherit system;

          config.allowUnfree = true;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = attrs // {inherit unstablePkgs;};
          modules = [
            disko.nixosModules.disko
            ./daedalus/modules
            ./daedalus/disko.nix
            ./daedalus/services
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sandro = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit unstablePkgs;

                recursiveUpdate = nixpkgs.lib.recursiveUpdate;
              };
            }
            {
              nixpkgs.config.permittedInsecurePackages = [
                # Sonarr dependencies
                "dotnet-sdk-6.0.428"
                "aspnetcore-runtime-6.0.36"
              ];

              nixpkgs.overlays = [
                (final: prev: {
                  jackett = prev.jackett.overrideAttrs {doCheck = false;};
                })
              ];
            }
          ];
        };

      homeConfigurations.sandro-darwin = let
        system = "aarch64-darwin";

        unsupportedPkgs = import nixpkgs {
          inherit system;

          config.allowUnfree = true;
        };

        unstablePkgs = import nixpkgs-unstable {
          inherit system;

          config.allowUnfree = true;
        };
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = {
            unfree-pkgs = unsupportedPkgs;
            recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate;
            unstablePkgs = unstablePkgs;
          };

          modules = [./home-darwin.nix];
        };

      homeConfigurations.sandro-linux = let
        system = "aarch64-linux";

        unsupportedPkgs = import nixpkgs {
          inherit system;

          config.allowUnfree = true;
        };

        unstablePkgs = import nixpkgs-unstable {
          inherit system;

          config.allowUnfree = true;
        };
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = {
            unfree-pkgs = unsupportedPkgs;
            recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate;
            unstablePkgs = unstablePkgs;
          };

          modules = [./home-linux.nix];
        };
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.alejandra;
      }
    );
}
