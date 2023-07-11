{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
  inputs.master-nixpkgs.url = github:NixOS/nixpkgs/master;

  inputs.home-manager = {
    url = github:nix-community/home-manager/release-23.05;

    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, master-nixpkgs, home-manager, flake-utils, ... }@attrs: rec {
    nixosConfigurations.mjollnir = 
      let
        system = "x86_64-linux";
        master-pkgs = import master-nixpkgs { inherit system; config.allowUnfree = true; };
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
            home-manager.extraSpecialArgs = { inherit master-pkgs; recursiveUpdate = nixpkgs.lib.recursiveUpdate; };
          }
        ];
      };

    homeConfigurations.sandro-darwin = 
      let 
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
          extraSpecialArgs = { recursiveUpdate = unsupportedPkgs.lib.recursiveUpdate; };

          modules = [ ./home-darwin.nix ]; 
        };

      
      packages.x86_64-linux.jetbrains-jdk = 
        let 
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        in
          pkgs.jetbrains.jdk.overrideAttrs (final: prev: rec {
            font-conf = ''
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
              <fontconfig>
                <!-- Original Config -->
                <!--
                <match target="font">
                  <test name="family" qual="all" compare="not_eq">
                    <string>Consolas</string>
                  </test>
                  <test name="family" qual="all" compare="not_eq">
                    <string>Noto Sans Mono CJK JP</string>
                  </test>
                  <test name="size" qual="any" compare="less">
                    <double>12</double>
                  </test>
                  <test name="weight" compare="less">
                    <const>medium</const>
                  </test>
                  <edit mode="assign" name="hintstyle">
                    <const>hintfull</const>
                  </edit>
                </match>
                -->
                
                <match target="pattern">
                  <edit name="hintstyle" mode="assign">
                    <const>hintslight</const>
                  </edit>
                  <edit name="antialias" mode="assign">
                    <bool>true</bool>
                  </edit>
                  <edit name="rgba" mode="assign">
                      <const>rgb</const>
                  </edit>
                </match>
              </fontconfig>
            '';

            installPhase = prev.installPhase + ''
              runHook postInstall
            '';

            postInstall = ''
              echo '${font-conf}' > $out/lib/openjdk/lib/fonts/font.conf
            '';
          });

      # Idea 2022.3, not yet available on nixpkgs
      packages.aarch64-darwin.idea-ultimate =
        let 
          pkgs = import master-nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
        in
          pkgs.jetbrains.idea-ultimate.overrideAttrs (final: previous: {
            pname = "idea";
            src = pkgs.fetchurl { url = "https://download.jetbrains.com/idea/ideaIU-2023.1.2-aarch64.dmg"; sha256 = "sha256-2K6Trel93TDJH9KoKHY7HJUujCBvBPvbnXnqIgeVWo4="; };
            version = "2023.1.2";
          });

      packages.x86_64-linux.idea-ultimate =
        let 
          pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        in
          pkgs.jetbrains.idea-ultimate.overrideAttrs (final: previous: {
            pname = "idea";
            src = pkgs.fetchurl { url = "https://download.jetbrains.com/idea/ideaIU-2022.3.tar.gz"; sha256 = "9675c15bea4b3d0e2b00265f1b4c7c775f4187cfda9b894b4109c90ceb8e3061"; };
            vmopts = "-Djava2d.font.loadFontConf=false"; # And grayscale AA set in the editor
            jdk = packages.x86_64-linux.jetbrains-jdk;
            version = "2022.3";
          });
      };
}
