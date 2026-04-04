{self, ...}: let
  lib = self.inputs.nixpkgs.lib;

  sshKeys = import "${self}/modules/ssh-keys.nix";
  mkPkgs = import ./modules/mk-pkgs.nix {
    inherit lib;
    overlays = self.overlays.all;
  };

  machineConfigs = {
    cheyenne = {
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/server.nix;
      buildHost = "root@joshua";
    };
    crystalpalace = {
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/server.nix;
      buildHost = "root@joshua";
    };
    joshua = {
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/joshua-nixos.nix;
    };
    wopr = {
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/wopr-nixos.nix;
    };
    falken = {
      tags = ["work"];
      system = "aarch64-linux";
      userModule = ./users/kent/falken-nixos.nix;
      requireExplicitUpdate = true;
    };
  };

  mkInventoryMachine = cfg: {
    inherit (cfg) tags;
  };

  mkMachine = cfg: {inputs, ...}:
    {
      nixpkgs.pkgs = mkPkgs inputs.nixpkgs cfg.system;
      imports = [cfg.userModule];
      users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];
    }
    // lib.optionalAttrs (cfg ? buildHost) {
      clan.core.networking.buildHost = cfg.buildHost;
    }
    // lib.optionalAttrs (cfg ? requireExplicitUpdate) {
      clan.core.deployment.requireExplicitUpdate = cfg.requireExplicitUpdate;
    };

  userInstanceConfigs = {
    sadbeast-user = {
      tags = ["personal"];
      user = "sadbeast";
      groups = ["wheel" "media"];
    };
    kent-user = {
      tags = ["work"];
      user = "kent";
      groups = ["wheel" "docker"];
    };
  };

  wifiInstanceConfig = {
    moduleInput = "clan-core";
    machineNetworks = {
      wopr = ["home"];
    };
  };

  mkUsersInstance = cfg: {
    module.name = "users";
    roles.default = {
      inherit (cfg) tags;
      settings = {
        inherit (cfg) groups user;
        share = true;
      };
    };
  };

  mkWifiMachineSettings = networks: {
    settings.networks = lib.genAttrs networks (_: {});
  };

  mkWifiInstance = cfg: {
    module.name = "wifi";
    module.input = cfg.moduleInput;
    roles.default.machines = lib.mapAttrs (_: mkWifiMachineSettings) cfg.machineNetworks;
  };
in {
  # Ensure this is unique among all clans you want to use.
  meta.name = "norad";
  meta.domain = "norad";

  inventory.machines = lib.mapAttrs (_: mkInventoryMachine) machineConfigs;

  inventory.instances =
    {
      wifi = mkWifiInstance wifiInstanceConfig;
      internet = {
        module.input = "clan-core";
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
      zerotier = {
        module.name = "zerotier";
        module.input = "clan-core";
        roles.controller.machines.cheyenne = {};
        roles.moon.machines.cheyenne.settings.stableEndpoints = ["149.248.36.246"];
        roles.peer.tags.personal = {};
        roles.peer.tags.work = {};
      };
    }
    // lib.mapAttrs (_: mkUsersInstance) userInstanceConfigs;

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = lib.mapAttrs (_: mkMachine) machineConfigs;
}
