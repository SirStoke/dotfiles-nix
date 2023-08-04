{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
  inputs.master-nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-23.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    master-nixpkgs,
    home-manager,
    flake-utils,
    ...
  } @ attrs:
    rec {
      nixosConfigurations.mjollnir = let
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
            ./modules
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sandro = import ./home-nixos.nix;
              home-manager.users.sandro-gaming = import ./home-nixos.nix;
              home-manager.extraSpecialArgs = {
                inherit master-pkgs;
                recursiveUpdate = nixpkgs.lib.recursiveUpdate;
              };
            }
          ];
        };

      homeConfigurations.sandro-darwin = let
        unsupportedPkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnsupportedSystem = true;
          config.allowUnfree = true;
        };
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = {recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate;};

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
