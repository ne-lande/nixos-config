{
  description = "sexOS :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      static = import ./static;
      secrets = import ./secrets;
      customModules = import ./modules;
      defaultHomeManager =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      defaultModules = [
        customModules
        home-manager.nixosModules.home-manager
        defaultHomeManager
        static
        secrets
      ];
      #customPackages = import ./packages { inherit pkgs; };
    in
    {
      nixosConfigurations = {
        "kasen" = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = defaultModules ++ [
            ./hosts/kasen
            ./home/nelande
            {
              home-manager.sharedModules = [
                plasma-manager.homeModules.plasma-manager
              ];
            }
          ];
        };

        "yuka" = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = defaultModules ++ [
            ./hosts/yuka
            ./home/nelande
          ];
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
