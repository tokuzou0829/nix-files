{
  description = "NixOS configuration with Home Manager and Secure Boot (Lanzaboote)";

  inputs = {
    # NixOS Unstable (共通)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }

          # 3. Lanzaboote モジュール
          lanzaboote.nixosModules.lanzaboote
          
          # 4. Lanzaboote 用のインライン設定
          ({ pkgs, lib, ... }: {
            environment.systemPackages = [
              # Secure Boot デバッグ・設定用ツール
              pkgs.sbctl
            ];
            # Lanzaboote は systemd-boot 
            boot.loader.systemd-boot.enable = lib.mkForce false;

            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })

        ];
      };
    };
  };
}