{
  self,
  lib,
  ...
}: let
  # Common configuration for all machines
  commonConfig = {
    nixpkgs.overlays = [
      self.overlays.additions
      self.overlays.modifications
    ];
  };
in {
  # Ensure this is unique among all clans you want to use.
  meta.name = "sadbeast";
  meta.tld = "com";

  inventory.machines = {
    cheyenne.deploy.targetHost = "root@cheyenne.sadbeast.com";
    crystalpalace.deploy.targetHost = "root@192.168.0.2";
    joshua.deploy.targetHost = "root@192.168.0.3";
    wopr.deploy.targetHost = "root@192.168.0.4";
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
        tags.all = {};
        settings = {
          user = "sadbeast";
          groups = ["wheel" "media"];
          share = true;
        };
      };
    };
  };

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = {
    cheyenne = lib.mkMerge [
      commonConfig
      {imports = [./users/sadbeast/server.nix];}
    ];
    crystalpalace = lib.mkMerge [
      commonConfig
      {imports = [./users/sadbeast/server.nix];}
    ];
    joshua = lib.mkMerge [
      commonConfig
      {imports = [./users/sadbeast/joshua-nixos.nix];}
    ];
    wopr = lib.mkMerge [
      commonConfig
      {imports = [./users/sadbeast/wopr-nixos.nix];}
    ];
  };
}
