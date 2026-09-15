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

    # omp coding agent; dont follow nixpkgs — its package pins bun2nix/rust-overlay
    # against upstream's locked nixpkgs, following would desync the nix-community cache
    omp = {
      url = "github:can1357/oh-my-pi";
    };

    # obv?
    secrets = {
      url = "path:/nix-secrets";
    };
    # secret provisioning; kasen renders via sops-nix — other hosts read
    # plain runtime files under /etc/secrets (never store paths)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      mkHost =
        { modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs mylib;
          };
          modules = defaultModules ++ modules;
        };
      defaultModules = [
        customModules
        home-manager.nixosModules.home-manager
        defaultHomeManager
        static
      ];
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      nixosConfigurations = {
        "kasen" = mkHost {
          modules = [
            disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./hosts/kasen/disko.nix
            ./hosts/kasen
            ./home/nelande
          ];
        };

        "yuka" = mkHost {
          modules = [
            ./hosts/yuka
            ./home/nelande
          ];
        };
      };
    };
}
