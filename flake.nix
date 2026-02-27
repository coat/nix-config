{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    nixpkgs-working.url = "github:nixos/nixpkgs/0182a361324364ae3f436a63005877674cf45efb";

    amp-nvim.url = "github:sourcegraph/amp.nvim";
    amp-nvim.flake = false;

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

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
    nixarr,
    nixpkgs,
    nixpkgs-working,
    nixvim,
    stylix,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;

    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});

    mkPkgs = import ./modules/mk-pkgs.nix {
      inherit lib;
      overlays = outputs.overlays.all;
    };

    mkPkgsFor = nixpkgsSrc:
      lib.genAttrs (import systems) (
        system: mkPkgs nixpkgsSrc system
      );

    pkgsFor = mkPkgsFor nixpkgs;

    # Shared home-manager modules for all targets.
    homeManagerSharedModules = [
      nixvim.homeModules.nixvim
      nix-index-database.homeModules.nix-index
    ];

    homeManagerStylixModules = [
      stylix.homeModules.stylix
      ./modules/stylix.nix
      {
        stylix = {
          autoEnable = false;
          targets.btop.enable = true;
          targets.fzf.enable = true;
          targets.nixvim.enable = true;
          targets.starship.enable = true;
          targets.tmux.enable = true;
        };
      }
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

    mkDevcontainer = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.${system};
        extraSpecialArgs = {inherit inputs outputs;};
        modules =
          [
            ./users/vscode/default.nix
          ]
          ++ homeManagerSharedModules
          ++ homeManagerStylixModules;
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

    # Standalone home-manager configs for non-NixOS targets only.
    # NixOS machines use clan + integrated home-manager.
    homeConfigurations = {
      "devcontainer-x86_64-linux" = mkDevcontainer "x86_64-linux";
      "devcontainer-aarch64-darwin" = mkDevcontainer "aarch64-darwin";
      "devcontainer-aarch64-linux" = mkDevcontainer "aarch64-linux";
    };

    darwinConfigurations."kents-MacBook-Pro" = darwin.lib.darwinSystem {
      specialArgs = {inherit inputs outputs;};
      modules = with home-manager; [
        ./hosts/darwin/work/configuration.nix
        {nixpkgs.overlays = outputs.overlays.all;}
        nix-index-database.darwinModules.nix-index
        darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs outputs;};
            sharedModules = homeManagerSharedModules ++ homeManagerStylixModules;
            users.kent = import ./users/kent/darwin.nix;
          };
        }
      ];
    };
  };
}
