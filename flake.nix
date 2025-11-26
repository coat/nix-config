{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    charm.url = "github:charmbracelet/nur";
    charm.inputs.nixpkgs.follows = "nixpkgs";

    clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
    clan-core.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixarr.url = "github:rasmus-kirk/nixarr";
    nixarr.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    systems.follows = "clan-core/systems";
  };

  outputs = {
    self,
    charm,
    clan-core,
    home-manager,
    nixpkgs,
    nixarr,
    systems,
    nixvim,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Usage see: https://docs.clan.lol
    clan = clan-core.lib.clan {
    inherit self;
      imports = [./clan.nix];
      specialArgs = {inherit inputs;};
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
  in {
    inherit (clan.config) nixosModules clanInternals;
    clan = clan.config;

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});

    overlays = import ./overlays {inherit inputs outputs;};

    # Add the Clan cli tool to the dev shell.
    # Use "nix develop" to enter the dev shell.
    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [clan-core.packages.${pkgs.stdenv.hostPlatform.system}.clan-cli];
      };
    });

    formatter = forEachSystem (pkgs: pkgs.alejandra);

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations =
      clan.config.nixosConfigurations
      // {
        wopr = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs outputs self;};
          modules = [
            ./machines/wopr/configuration.nix
          ];
        };
      };

    homeConfigurations = {
      "sadbeast@wopr" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          nixvim.homeModules.nixvim
          ./users/sadbeast/wopr.nix
        ];
      };
    };
  };
}
