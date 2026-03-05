{
  description = "sexOS :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # not free, dont try
    bpf = {
      url = "git+ssh://git@binarybears-notes.ru:2424/tools/bpf.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    # not free, dont try
    ipoc = {
      url = "git+ssh://git@binarybears-notes.ru:2424/tools/ida-pro-on-crack.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    zed = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      plasma-manager,
      bpf,
      ipoc,
      zed,
      ...
    }:
    let
      system = "x86_64-linux";

      #mylib = import ./lib { inherit lib; };
      static = import ./static;
      secrets = import ./secrets;
      customModules = import ./modules;
      #mypacks = import ./packages { inherit inputs; };
      defaultHomeManager = { inputs, ... }: {
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;
            sharedModules = [
              plasma-manager.homeModules.plasma-manager
            ];
          };
        };
      defaultModules = [
        #mypacks
        customModules
        home-manager.nixosModules.home-manager
        defaultHomeManager
        static
        secrets
        #mylib
      ];
    in
    {
      nixosConfigurations = {
        "kasen" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = defaultModules ++ [
            ./hosts/kasen
            ./home/nelande
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
