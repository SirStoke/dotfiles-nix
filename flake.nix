{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
  inputs.nixpkgs-unstable.url = github:NixOS/nixpkgs/nixos-unstable;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-24.11;

    inputs.nixpkgs.follows = "nixpkgs";
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
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        formatter = pkgs.alejandra;
      }
    );
}
