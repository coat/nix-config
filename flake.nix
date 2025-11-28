{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    charm.url = "github:charmbracelet/nur";
    charm.inputs.nixpkgs.follows = "nixpkgs";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixarr.url = "github:rasmus-kirk/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    systems.follows = "clan-core/systems";
  };

  outputs = {
    self,
    charm,
    clan-core,
    darwin,
    home-manager,
    nix-index-database,
    nixarr,
    nixpkgs,
    nixvim,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Usage see: https://docs.clan.lol
    clan = clan-core.lib.clan {
      inherit self;
      imports = [./clan.nix];
      specialArgs = {inherit inputs self outputs;};
    };
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
          ];
        }
    );
    # Helper to create home-manager configurations with common modules
    mkHomeConfiguration = {
      pkgs,
      modules,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules =
          [
            inputs.nix-index-database.homeModules.nix-index
            nixvim.homeModules.nixvim
          ]
          ++ modules;
      };
  in {
    inherit (clan.config) nixosModules clanInternals;
    clan = clan.config;

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    overlays = import ./overlays {inherit inputs outputs;};

    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [clan-core.packages.${pkgs.stdenv.hostPlatform.system}.clan-cli];
      };
    });

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = clan.config.nixosConfigurations;

    homeConfigurations = {
      "sadbeast@wopr" = mkHomeConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [./users/sadbeast/wopr.nix];
      };

      "sadbeast@joshua" = mkHomeConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [./users/sadbeast/joshua.nix];
      };

      "devcontainer" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.aarch64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./users/vscode/default.nix];
      };
    };

    darwinConfigurations."kents-MacBook-Pro" = darwin.lib.darwinSystem {
      # pkgs = pkgsFor.aarch64-darwin;
      modules = [
        ./machines/work/configuration.nix
        nix-index-database.darwinModules.nix-index
        home-manager.darwinModules.home-manager
        {
          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {inherit inputs outputs;};
          home-manager.users.kent = import ./home/kent/work.nix;
        }
      ];
    };
  };
}