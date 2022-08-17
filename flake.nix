{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-22.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };
  
  outputs = { self, nixpkgs, home-manager, ... }@attrs: rec {
    nixosConfigurations.loki = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = attrs;
      modules = [ 
        ./modules
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sandro = import ./home.nix;
        }
      ];
    };
  };
}
