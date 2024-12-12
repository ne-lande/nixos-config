{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nix-ld, nixpkgs, home-manager, plasma-manager, spicetify-nix, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      "kasen" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/kasen/default.nix
          ./home/nelande/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.users."nelande" = (import ./home/nelande/home-manager.nix {inherit spicetify-nix;});
          }
        ];
      };

      "yuka" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./home/nelande/default.nix
          ./hosts/yuka/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
            home-manager.users."nelande" = (import ./home/nelande/home-manager.nix {inherit spicetify-nix;});
          }
        ];
      };
    };
  };
}
