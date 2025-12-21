{
  # Ensure this is unique among all clans you want to use.
  meta.name = "sadbeast";
  meta.tld = "com";

  inventory.machines = {
    crystalpalace = {
      deploy.targetHost = "root@192.168.0.2";
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

    sadbeast-user = {
      module.name = "users";

      roles.default.tags.all = {};

      roles.default.settings = {
        user = "sadbeast";
        groups = ["wheel" "media"];
      };

      roles.default.extraModules = [./users/sadbeast/crystalpalace.nix];
    };
  };

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = {
    crystalpalace = {config, ...}: {};
  };
}
