# Guest config shared by every microvms/*.nix. Extra attrs in the VM file
# (user, authorizedKeys, homeImports, userCA, sshProxyPort) are optional overrides;
# sshProxyPort is consumed host-side in microvm.nix and ignored here.
cfg @ {
  hostName,
  ipAddress,
  tapId,
  mac,
  workspace,
  vsockCid,
  inputs,
  outputs,
  homeManagerSharedModules,
  user ? "sadbeast",
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  sshKeys = import ../lib/ssh-keys.nix;
  authorizedKeys = cfg.authorizedKeys or sshKeys.${user};
  homeImports =
    cfg.homeImports
    or [
      (../users + "/${user}/home.nix")
      ../users/features/dev.nix
    ];
in {
  imports = [
    inputs.home-manager.nixosModules.default
    ./home-manager-stylix.nix
  ];

  _module.args.inputs = inputs;

  nix.settings = {
    experimental-features = ["ca-derivations" "nix-command" "flakes"];
    auto-optimise-store = false;
    substituters = ["https://cache.numtide.com"];
    trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    trusted-users = ["@wheel"];
  };

  microvm = {
    hypervisor = "cloud-hypervisor";
    vcpu = 4;
    mem = 4096;

    vsock.cid = vsockCid;

    interfaces = [
      {
        type = "tap";
        id = tapId;
        inherit mac;
      }
    ];

    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        proto = "virtiofs";
      }
      {
        tag = "workspace";
        source = workspace;
        mountPoint = "/home/${user}/workspace";
        proto = "virtiofs";
      }
    ];

    volumes = [
      {
        image = "var.img";
        mountPoint = "/var";
        size = 8192;
      }
      # Root is tmpfs; keep herdr session state, agent logins and shell
      # history across VM restarts.
      {
        image = "home.img";
        mountPoint = "/home";
        size = 4096;
      }
    ];

    writableStoreOverlay = "/nix/.rw-store";
  };

  networking.hostName = hostName;

  systemd.network = {
    enable = true;
    networks."20-lan" = {
      matchConfig.Type = "ether";
      networkConfig = {
        Address = ipAddress;
        Gateway = "192.168.83.1";
        DNS = ["1.1.1.1" "1.0.0.1"];
      };
    };
  };

  services.resolved.enable = true;

  # sshd generates the key on first boot; /var is a persistent volume, so the
  # host key survives rebuilds without any host-side setup.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [user];
    };
    hostKeys = [
      {
        path = "/var/lib/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
    # Certificates signed by userCA (a public key file) are accepted for
    # principals matching the login user; see pkgs/pair-invite.
    extraConfig = lib.optionalString (cfg ? userCA) ''
      TrustedUserCAKeys ${cfg.userCA}
    '';
  };

  # uid 1000 is pinned because virtiofs maps ids 1:1 and microvm.nix chowns
  # the host-side workspace to 1000.
  users.users.${user} = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = authorizedKeys;
  };

  # The workspace share is mounted before users are created, so systemd
  # makes /home/<user> as root and NixOS then leaves the existing dir alone.
  systemd.tmpfiles.rules = ["d /home/${user} 0700 ${user} users -"];

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs outputs;
      nixosConfig = config;
    };
    sharedModules = homeManagerSharedModules;
    users.${user}.imports = homeImports;
  };

  system.stateVersion = "25.11";
}
