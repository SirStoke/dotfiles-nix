{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
  inputs.master-nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-24.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nix-alien.url = "github:thiagokokada/nix-alien/master";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    master-nixpkgs,
    home-manager,
    flake-utils,
    nix-alien,
    disko,
    ...
  } @ attrs:
    rec {
      nixosConfigurations.mjollnir = let
        system = "x86_64-linux";

        master-pkgs = import master-nixpkgs {
          inherit system;

          config.allowUnfree = true;
          config.permittedInsecurePackages = [
            "electron-25.9.0"
          ];
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
                inherit master-pkgs;
                nix-alien-pkgs = nix-alien.packages.${system};
                recursiveUpdate = nixpkgs.lib.recursiveUpdate;
              };
            }
          ];
        };

      nixosConfigurations.daedalus = let
        system = "x86_64-linux";

        master-pkgs = import master-nixpkgs {
          inherit system;

          config.allowUnfree = true;
        };
      in
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = attrs;
          modules = [
            disko.nixosModules.disko
            ./daedalus/modules
            ./daedalus/disko.nix
            ./daedalus/services/plex
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sandro = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit master-pkgs;
                recursiveUpdate = nixpkgs.lib.recursiveUpdate;
              };
            }
          ];
        };

      homeConfigurations.sandro-darwin = let
        system = "aarch64-darwin";

        unsupportedPkgs = import nixpkgs {
          inherit system;
          config.allowUnsupportedSystem = true;
          config.allowUnfree = true;
        };

        master-pkgs = import master-nixpkgs {
          inherit system;

          config.allowUnfree = true;
        };
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = {
            inherit master-pkgs;

            unfree-pkgs = unsupportedPkgs;

            recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate;
          };

          modules = [./home-darwin.nix];
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
