{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  inputs.master-nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-22.11;

    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, master-nixpkgs, home-manager, flake-utils, ... }@attrs: {
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
            home-manager.users.sandro-gaming = import ./home-nixos.nix;
            home-manager.extraSpecialArgs = { inherit master-pkgs; recursiveUpdate = nixpkgs.lib.recursiveUpdate; };
          }
        ];
      };

    homeConfigurations.sandro-darwin = 
      let 
        unsupportedPkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnsupportedSystem = true; };
      in
        home-manager.lib.homeManagerConfiguration rec {
          pkgs = unsupportedPkgs;

          # Let's pass pkgs.lib.recursiveUpdate as a standalone arg, to avoid a circular dependency when merging
          # configurations
          extraSpecialArgs = { recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate; };

          modules = [ ./home-darwin.nix ]; 
        };

      # Idea 2022.3, not yet available on nixpkgs
      packages.aarch64-darwin.idea-ultimate =
        let 
          pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
        in
          pkgs.jetbrains.idea-ultimate.overrideAttrs (final: previous: {
            pname = "idea";
            src = pkgs.fetchurl { url = "https://download.jetbrains.com/idea/ideaIU-2022.3-aarch64.dmg"; sha256 = "sha256-2IW1c0Qur/zNMMKRryKOXVcYv/LCNyLIzaLRviVUls8=";};
            version = "2022.3";
          });

      packages.x86_64-linux.idea-ultimate =
        let 
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        in
          pkgs.jetbrains.idea-ultimate.overrideAttrs (final: previous: {
            pname = "idea";
            src = pkgs.fetchurl { url = "https://download.jetbrains.com/idea/ideaIU-2022.3.tar.gz"; sha256 = "9675c15bea4b3d0e2b00265f1b4c7c775f4187cfda9b894b4109c90ceb8e3061"; };
            version = "2022.3";
          });
      };
}
