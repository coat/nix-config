{self, ...}: let
  sshKeys = import "${self}/modules/ssh-keys.nix";

  mkPkgs = nixpkgsSrc: system: let
    lib = nixpkgsSrc.lib;
  in
    import nixpkgsSrc {
      inherit system;
      config.allowUnfree = true;
      config.allowInsecurePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "librewolf-bin"
          "librewolf-bin-unwrapped"
        ];
      overlays = self.overlays.all;
    };
in {
  # Ensure this is unique among all clans you want to use.
  meta.name = "norad";
  meta.domain = "norad";

  inventory.machines = {
    cheyenne = {
      deploy.targetHost = "root@cheyenne.sadbeast.com";
      tags = ["personal"];
    };
    crystalpalace = {
      deploy.targetHost = "root@crystalpalace";
      tags = ["personal"];
    };
    joshua = {
      deploy.targetHost = "root@joshua";
      tags = ["personal"];
    };
    wopr = {
      deploy.targetHost = "root@wopr";
      tags = ["personal"];
    };
    falken = {
      deploy.targetHost = "root@192.168.0.101";
      tags = ["work"];
    };
  };

  inventory.instances = {
    wifi = {
      module.name = "wifi";
      module.input = "clan-core";

      roles.default = {
        machines."wopr" = {
          settings.networks.home = {};
        };
      };
    };

    sadbeast-user = {
      module.name = "users";
      roles.default = {
        tags = ["personal"];
        settings = {
          user = "sadbeast";
          groups = ["wheel" "media"];
          share = true;
        };
      };
    };

    kent-user = {
      module.name = "users";
      roles.default = {
        tags = ["work"];
        settings = {
          user = "kent";
          groups = ["wheel" "docker"];
          share = true;
        };
      };
    };
  };

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = {
    cheyenne = {inputs, ...}: {
      # nixpkgs.pkgs = mkPkgs inputs.nixpkgs-stable "x86_64-linux";
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/server.nix];
      clan.core.networking.buildHost = "root@crystalpalace";
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];
    };
    crystalpalace = {inputs, ...}: {
      # nixpkgs.pkgs = mkPkgs inputs.nixpkgs-stable "x86_64-linux";
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/server.nix];
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];
    };
    joshua = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/joshua-nixos.nix];
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];
    };
    wopr = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/wopr-nixos.nix];
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];
    };
    falken = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "aarch64-linux";
      imports = [./users/kent/falken-nixos.nix];
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];

      clan.core.deployment.requireExplicitUpdate = true;
    };
  };
}
