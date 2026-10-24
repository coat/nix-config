{self, ...}: let
  lib = self.inputs.nixpkgs.lib;

  sshKeys = import "${self}/lib/ssh-keys.nix";

  # Each machine declares its tags, system, and the *profile* + *user* that
  # parameterise module composition:
  #   modules/global.nix               every machine
  #   modules/profiles/<profile>.nix   desktop | server | vm
  #   users/<user>/nixos.nix           the user's system account
  #   users/<user>/<profile>.nix       optional: user additions for that profile
  #   users/<user>/home.nix            the user's home-manager bundle
  #   machines/<host>/home.nix         optional: per-host HM tweaks
  # machines/<host>/{configuration,disko}.nix and facter.json are
  # auto-imported by clan.
  machineConfigs = {
    cheyenne = {
      tags = ["personal"];
      system = "x86_64-linux";
      profile = "server";
      user = "sadbeast";
      buildHost = "root@joshua";
    };
    crystalpalace = {
      tags = ["personal"];
      system = "x86_64-linux";
      profile = "server";
      user = "sadbeast";
      buildHost = "root@joshua";
    };
    joshua = {
      tags = ["personal"];
      system = "x86_64-linux";
      profile = "desktop";
      user = "sadbeast";
    };
    wopr = {
      tags = ["personal"];
      system = "x86_64-linux";
      profile = "desktop";
      user = "sadbeast";
      buildHost = "root@joshua";
    };
    falken = {
      tags = ["work"];
      system = "aarch64-linux";
      profile = "vm";
      user = "kent.smith";
      requireExplicitUpdate = true;
    };
  };

  mkMachine = name: cfg: {pkgsFor, ...}: let
    optionalFile = path: lib.optional (builtins.pathExists path) path;
    userDir = ./users + "/${cfg.user}";
  in {
    nixpkgs.pkgs = pkgsFor.${cfg.system};

    imports =
      [
        ./modules/global.nix
        ./modules/home-manager.nix
        (./modules/profiles + "/${cfg.profile}.nix")
        (userDir + "/nixos.nix")
      ]
      ++ optionalFile (userDir + "/${cfg.profile}.nix");

    users.users.root.openssh.authorizedKeys.keys = [sshKeys.primary];

    home-manager.users.${cfg.user}.imports =
      [(userDir + "/home.nix")]
      ++ optionalFile (./machines + "/${name}/home.nix");

    clan.core.networking.buildHost = lib.mkIf (cfg ? buildHost) cfg.buildHost;
    clan.core.deployment.requireExplicitUpdate = lib.mkIf (cfg ? requireExplicitUpdate) cfg.requireExplicitUpdate;
  };

  # One clan `users` instance per account; tags pick the machines it lands on.
  userInstanceConfigs = {
    sadbeast = {
      tags = ["personal"];
      groups = ["wheel" "media" "docker" "audio" "input"];
    };
    "kent.smith" = {
      tags = ["work"];
      groups = ["wheel" "docker"];
    };
  };

  mkUsersInstance = user: cfg: {
    name = "${user}-user";
    value = {
      module.name = "users";
      roles.default = {
        inherit (cfg) tags;
        settings = {
          inherit user;
          inherit (cfg) groups;
          share = true;
        };
      };
    };
  };
in {
  # Ensure this is unique among all clans you want to use.
  meta.name = "norad";
  meta.domain = "norad";

  inventory.machines = lib.mapAttrs (_: cfg: {inherit (cfg) tags;}) machineConfigs;

  inventory.instances =
    {
      wifi = {
        module.name = "wifi";
        module.input = "clan-core";
        roles.default.machines.wopr.settings.networks.home = {};
      };
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
      # Obsidian vault (users/sadbeast/desktop-home.nix). crystalpalace is the
      # always-on peer so the phone can sync without a desktop running.
      syncthing = {
        module.name = "syncthing";
        module.input = "clan-core";
        roles.peer.machines.joshua = {};
        roles.peer.machines.wopr = {};
        roles.peer.machines.crystalpalace = {};
        roles.peer.extraModules = [./modules/syncthing-vault.nix];
        roles.peer.settings.folders.obsidian-personal = {
          path = "/home/sadbeast/docs/vault/personal";
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        roles.peer.settings.extraDevices.phone = {
          id = "OFB2Z7W-CV5XFLE-T4ZTTPV-5RIFKWD-MAPG4BD-LB4RRY4-V3UXNQE-MNK3BAJ";
          name = "phone";
        };
      };
    }
    // lib.mapAttrs' mkUsersInstance userInstanceConfigs;

  machines = lib.mapAttrs mkMachine machineConfigs;
}
