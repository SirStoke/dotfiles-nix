{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
  inputs.master-nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-22.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, master-nixpkgs, home-manager, ... }@attrs: {
    nixosConfigurations.loki = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = attrs;
      modules = [ 
        ./modules
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sandro = import ./home-nixos.nix;
        }
      ];
    };

    nixosConfigurations.mjollnir = 
      let
        system = "x86_64-linux";
        master-pkgs = import master-nixpkgs { inherit system; config.allowUnfree = true; };
      in 
      nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = attrs;
        modules = [
          ./modules-mjollnir
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sandro = import ./home-nixos.nix;
            home-manager.extraSpecialArgs = { inherit master-pkgs; recursiveUpdate = nixpkgs.lib.recursiveUpdate; };
          }
        ];
      };

    homeConfigurations.sandro-darwin = 
      let 
        unsupportedPkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnsupportedSystem = true; };
      in
        home-manager.lib.homeManagerConfiguration rec {
          system = "aarch64-darwin";
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = { recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate; };

          configuration = import ./home-darwin.nix; 
          homeDirectory = "/users/Sandro";
          username = "sandro";
        };
  };
}
