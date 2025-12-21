{self, ...}: let
  # Common overlays for all machines
  commonOverlays = [
    self.overlays.additions
    self.overlays.modifications
  ];

  mkPkgs = nixpkgsSrc: system:
    import nixpkgsSrc {
      inherit system;
      config.allowUnfree = true;
      overlays = commonOverlays;
    };
in {
  # Ensure this is unique among all clans you want to use.
  meta.name = "sadbeast";
  meta.tld = "com";

  inventory.machines = {
    cheyenne = {
      deploy.targetHost = "root@cheyenne.sadbeast.com";
      tags = ["personal"];
    };
    crystalpalace = {
      deploy.targetHost = "root@crystalpalace.local";
      tags = ["personal"];
    };
    joshua = {
      deploy.targetHost = "root@joshua.local";
      tags = ["personal"];
    };
    wopr = {
      deploy.targetHost = "root@wopr.local";
      tags = ["personal"];
    };
    falken = {
      deploy.targetHost = "root@192.168.0.101";
      tags = ["work"];
    };
  };

  # Docs: See https://docs.clan.lol/reference/clanServices
  inventory.instances = {
    # Docs: https://docs.clan.lol/reference/clanServices/admin/
    # Admin service for managing machines
    # This service adds a root password and SSH access.
    admin = {
      roles.default.tags.all = {};
      roles.default.settings.allowedKeys."sadbeast" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpEusv/bS34Q1JQxZXikdcwnq1vToz2d+HgV+E8NRX";
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
      clan.core.networking.buildHost = "root@crystalpalace.local";
    };
    crystalpalace = {inputs, ...}: {
      # nixpkgs.pkgs = mkPkgs inputs.nixpkgs-stable "x86_64-linux";
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/server.nix];
    };
    joshua = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/joshua-nixos.nix];
    };
    wopr = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "x86_64-linux";
      imports = [./users/sadbeast/wopr-nixos.nix];
    };
    falken = {inputs, ...}: {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs "aarch64-linux";
      imports = [./users/kent/falken-nixos.nix];
    };
  };
}
