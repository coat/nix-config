{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/25.11.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";

    nixarr.url = "github:rasmus-kirk/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    systems.follows = "clan-core/systems";
  };

  outputs = {
    self,
    clan-core,
    darwin,
    home-manager,
    nix-index-database,
    nixpkgs,
    nixvim,
    stylix,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;

    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

    mkPkgs = import ./lib/mk-pkgs.nix {
      inherit lib;
      overlays = [outputs.overlays.all];
    };

    mkPkgsFor = nixpkgsSrc:
      lib.genAttrs (import systems) (
        system: mkPkgs nixpkgsSrc system
      );

    pkgsFor = mkPkgsFor nixpkgs;

    # Shared home-manager modules for clan + standalone + darwin.
    homeManagerSharedModules = [
      nixvim.homeModules.nixvim
      nix-index-database.homeModules.nix-index
      {programs.nixvim.nixpkgs.source = nixpkgs;}
    ];

    homeManagerStylixModules = [
      stylix.homeModules.stylix
      ./modules/stylix.nix
    ];

    # Usage see: https://docs.clan.lol
    clan = clan-core.lib.clan {
      inherit self;
      imports = [./clan.nix];
      specialArgs = {
        inherit
          homeManagerSharedModules
          inputs
          outputs
          self
          ;
      };
    };

    # Standalone home-manager (devcontainers, nix-on-droid).
    # Each entry: { system, module }.
    standaloneHomeConfigs = {
      "devcontainer-x86_64-linux" = {
        system = "x86_64-linux";
        module = ./users/vscode/default.nix;
      };
      "devcontainer-aarch64-darwin" = {
        system = "aarch64-darwin";
        module = ./users/vscode/default.nix;
      };
      "devcontainer-aarch64-linux" = {
        system = "aarch64-linux";
        module = ./users/vscode/default.nix;
      };
    };

    mkStandaloneHome = cfg:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.${cfg.system};
        extraSpecialArgs = {inherit inputs outputs;};
        modules =
          [cfg.module]
          ++ homeManagerSharedModules
          ++ homeManagerStylixModules;
      };

    # Darwin hosts. Each entry: { system, user, hostConfig }.
    darwinHostConfigs = let
      workIdentity = import ./users/kent/identity.nix;
    in {
      "kents-MacBook-Pro" = {
        system = "aarch64-darwin";
        user = workIdentity.username;
        hostConfig = ./hosts/darwin/work/configuration.nix;
      };
    };

    mkDarwin = cfg:
      darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs outputs;
          username = cfg.user;
        };
        modules = [
          cfg.hostConfig
          {nixpkgs.overlays = [outputs.overlays.all];}
          nix-index-database.darwinModules.nix-index
          stylix.darwinModules.stylix
          ./modules/stylix.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs outputs;};
              sharedModules = homeManagerSharedModules;
              users.${cfg.user} = import (./users + "/${cfg.user}/darwin.nix");
            };
          }
        ];
      };
  in {
    inherit (clan.config) nixosModules clanInternals;
    clan = clan.config;

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    overlays = import ./overlays {inherit inputs outputs;};

    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [
          clan-core.packages.${pkgs.stdenv.hostPlatform.system}.clan-cli
          pkgs.sops
        ];
      };
    });

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = clan.config.nixosConfigurations;

    # Standalone home-manager configs for non-NixOS targets (devcontainers).
    # NixOS machines use clan + integrated home-manager.
    homeConfigurations = lib.mapAttrs (_: mkStandaloneHome) standaloneHomeConfigs;

    darwinConfigurations = lib.mapAttrs (_: mkDarwin) darwinHostConfigs;
  };
}
