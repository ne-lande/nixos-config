{
  description = "sexOS :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    static = import ./static;
    secrets = import ./secrets;
    customModules = import ./modules;
    defaultHomeManager = { config, lib, pkgs, ... }: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
    defaultModules = [ customModules home-manager.nixosModules.home-manager defaultHomeManager static secrets ];
  in
  {
    nixosConfigurations = {
      "kasen" = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = defaultModules ++ [
          ./hosts/kasen
          ./home/nelande
          { home-manager.sharedModules = [
              spicetify-nix.homeManagerModules.default
              plasma-manager.homeManagerModules.plasma-manager
          ]; }
        ];

        specialArgs = {
          inherit spicetify-nix;
        };
      };

      "yuka" = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = defaultModules ++ [
          ./hosts/yuka
          ./home/nelande
          { home-manager.sharedModules = [
              spicetify-nix.homeManagerModules.default
          ]; }
        ];

        specialArgs = {
          inherit spicetify-nix;
        };
      };

      "abashed" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = defaultModules ++ [
          ./hosts/abashed
          ./home/honeset
        ];
      };
    };
  };
}
