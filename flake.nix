{
  description = "sexOS :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # obv?
    secrets = {
      url = "path:/nix-secrets";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      disko,
      bpf,
      ipoc,
      secrets,
      ...
    }:
    let
      system = "x86_64-linux";

      mylib = import ./lib;
      static = import ./static;
      customModules = import ./modules;
      defaultHomeManager =
        { inputs, ... }:
        {
          home-manager = {
            extraSpecialArgs = { inherit inputs; };
            useGlobalPkgs = true;
            useUserPackages = true;

          };
        };
      defaultModules = [
        customModules
        home-manager.nixosModules.home-manager
        defaultHomeManager
        static
      ];
    in
    {
      nixosConfigurations = {
        "kasen" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs mylib; };

          modules = defaultModules ++ [
            disko.nixosModules.disko
            ./hosts/kasen/disko.nix
            ./hosts/kasen
            ./home/nelande
          ];
        };

        "yuka" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs mylib; };

          modules = defaultModules ++ [
            ./hosts/yuka
            ./home/nelande
          ];
        };

        "abashed" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs mylib; };
          modules = defaultModules ++ [
            ./hosts/abashed
            ./home/honeset
          ];
        };
      };
    };
}
