{self, ...}: {
  # Ensure this is unique among all clans you want to use.
  meta.name = "sadbeast";
  meta.tld = "com";

  inventory.machines = {
    cheyenne = {
      deploy.targetHost = "root@cheyenne.sadbeast.com";
      tags = ["server"];
    };
    crystalpalace = {
      deploy.targetHost = "root@192.168.0.2";
      tags = ["server"];
    };
    joshua = {
      deploy.targetHost = "root@192.168.0.3";
      tags = ["desktop"];
    };
    wopr = {
      deploy.targetHost = "root@192.168.0.4";
      tags = ["desktop"];
    };
  };

  # Docs: See https://docs.clan.lol/reference/clanServices
  inventory.instances = {
    # Docs: https://docs.clan.lol/reference/clanServices/admin/
    # Admin service for managing machines
    # This service adds a root password and SSH access.
    admin = {
      roles.default.tags.all = {};
      roles.default.settings.allowedKeys = {
        # Insert the public key that you want to use for SSH access.
        # All keys will have ssh access to all machines ("tags.all" means 'all machines').
        # Alternatively set 'users.users.root.openssh.authorizedKeys.keys' in each machine
        "sadbeast" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINGpEusv/bS34Q1JQxZXikdcwnq1vToz2d+HgV+E8NRX";
      };
    };

    internet = {
      roles.default.machines.cheyenne = {
        settings.host = "cheyenne.sadbeast.com";
      };
      roles.default.machines.crystalpalace = {
        settings.host = "192.168.0.2";
      };
      roles.default.machines.joshua = {
        settings.host = "192.168.0.3";
      };
      roles.default.machines.wopr = {
        settings.host = "192.168.0.4";
      };
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
    cheyenne = {config, ...}: {
      imports = [./users/sadbeast/server.nix];
      nixpkgs.overlays = [
        self.overlays.additions
        self.overlays.modifications
      ];
    };
    crystalpalace = {config, ...}: {
      imports = [./users/sadbeast/server.nix];
      nixpkgs.overlays = [
        self.overlays.additions
        self.overlays.modifications
      ];
    };
    joshua = {config, ...}: {
      imports = [./users/sadbeast/joshua-nixos.nix];
      nixpkgs.overlays = [
        self.overlays.additions
        self.overlays.modifications
      ];
    };
    wopr = {config, ...}: {
      imports = [./users/sadbeast/wopr-nixos.nix];
      nixpkgs.overlays = [
        self.overlays.additions
        self.overlays.modifications
      ];
    };
  };
}
