{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/26.05.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    herdr.url = "github:herdrdev/herdr";
    herdr.inputs.nixpkgs.follows = "nixpkgs";

    # Only used for its home-manager module; the package comes from nixpkgs.
    hunk.url = "github:modem-dev/hunk";
    hunk.flake = false;

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    kitehost-nvim.url = "github:selimacerbas/kitehost.nvim";
    kitehost-nvim.flake = false;

    mdkite-nvim.url = "github:selimacerbas/mdkite.nvim";
    mdkite-nvim.flake = false;

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

    # One nixpkgs instance per system (overlays + unfree), shared by clan
    # machines, darwin and standalone home-manager.
    pkgsFor = lib.genAttrs (import systems) (
      import ./lib/mk-pkgs.nix {overlays = [outputs.overlays.all];} nixpkgs
    );

    # Home-manager modules every HM user gets (clan, microvm, darwin, standalone).
    homeManagerSharedModules = [
      nixvim.homeModules.nixvim
      nix-index-database.homeModules.nix-index
      {programs.nixvim.nixpkgs.source = nixpkgs;}
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
          pkgsFor
          self
          ;
      };
    };

    # Standalone home-manager for devcontainers: `devcontainer-<system>`.
    mkStandaloneHome = system:
      home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.${system};
        extraSpecialArgs = {inherit inputs outputs;};
        modules =
          [
            ./users/vscode/default.nix
            ./modules/stylix/hm-terminal.nix
          ]
          ++ homeManagerSharedModules;
      };

    devcontainerSystems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

    # Darwin hosts (not clan-managed). Each entry: { system, user, hostConfig }.
    darwinHostConfigs = {
      "k-smith-3qcj" = {
        system = "aarch64-darwin";
        user = (import ./users/kent.smith/identity.nix).username;
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
          {nixpkgs.pkgs = pkgsFor.${cfg.system};}
          nix-index-database.darwinModules.nix-index
          stylix.darwinModules.stylix
          ./modules/stylix/theme.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit inputs outputs;};
              sharedModules = homeManagerSharedModules ++ [./modules/stylix/hm-targets.nix];
              users.${cfg.user} = import (./users + "/${cfg.user}/darwin.nix");
            };
          }
        ];
      };
  in {
    inherit (clan.config) nixosModules clanInternals;
    clan = clan.config;

    # Only expose packages whose meta.platforms include the system, so
    # `nix flake check` doesn't trip over Linux-only packages on darwin.
    packages = forEachSystem (pkgs:
      lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform)
      (import ./pkgs {inherit pkgs;}));

    overlays = import ./overlays {inherit inputs;};

    devShells = forEachSystem (pkgs: let
      # nixpkgs now builds python packages with __structuredAttrs, so each
      # makeWrapperArgs element is passed as one argument and clan-cli's
      # "--unset LD_LIBRARY_PATH" fails the build. Split those elements.
      # Drop once clan-core lists them as separate elements.
      clan-cli = clan-core.packages.${pkgs.stdenv.hostPlatform.system}.clan-cli.overridePythonAttrs (old: {
        makeWrapperArgs = lib.concatMap (arg:
          if lib.hasPrefix "--unset " arg
          then lib.splitString " " arg
          else [arg])
        old.makeWrapperArgs;
      });
    in {
      default = pkgs.mkShell {
        packages = [
          clan-cli
          pkgs.sops
        ];
      };
    });

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    nixosConfigurations = clan.config.nixosConfigurations;

    # Standalone home-manager configs for non-NixOS targets (devcontainers).
    # NixOS machines use clan + integrated home-manager.
    homeConfigurations = lib.listToAttrs (map (system: lib.nameValuePair "devcontainer-${system}" (mkStandaloneHome system)) devcontainerSystems);

    darwinConfigurations = lib.mapAttrs (_: mkDarwin) darwinHostConfigs;
  };
}
