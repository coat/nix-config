{self, ...}: let
  lib = self.inputs.nixpkgs.lib;

  sshKeys = import "${self}/modules/ssh-keys.nix";
  mkPkgs = import ./modules/mk-pkgs.nix {
    inherit lib;
    overlays = self.overlays.all;
  };

  machineConfigs = {
    cheyenne = {
      targetHost = "root@cheyenne.sadbeast.com";
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/server.nix;
      buildHost = "root@crystalpalace";
    };
    crystalpalace = {
      targetHost = "root@crystalpalace";
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/server.nix;
    };
    joshua = {
      targetHost = "root@joshua";
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/joshua-nixos.nix;
    };
    wopr = {
      targetHost = "root@wopr";
      tags = ["personal"];
      system = "x86_64-linux";
      userModule = ./users/sadbeast/wopr-nixos.nix;
    };
    falken = {
      targetHost = "root@192.168.0.101";
      tags = ["work"];
      system = "aarch64-linux";
      userModule = ./users/kent/falken-nixos.nix;
      requireExplicitUpdate = true;
    };
  };

  mkInventoryMachine = cfg: {
    deploy.targetHost = cfg.targetHost;
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
    }
    // lib.mapAttrs (_: mkUsersInstance) userInstanceConfigs;

  # Additional NixOS configuration can be added here.
  # machines/jon/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/guides/more-machines/#automatic-registration
  machines = lib.mapAttrs (_: mkMachine) machineConfigs;
}
