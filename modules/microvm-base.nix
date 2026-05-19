{
  hostName,
  ipAddress,
  tapId,
  mac,
  workspace,
  vsockCid,
  inputs,
  outputs,
  homeManagerSharedModules,
}: {
  config,
  pkgs,
  ...
}: let
  sshKeys = import ../lib/ssh-keys.nix;
in {
  imports = [
    inputs.home-manager.nixosModules.default
    ./home-manager-stylix.nix
  ];

  _module.args.inputs = inputs;

  nix.settings = {
    experimental-features = "ca-derivations nix-command flakes";
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
        mountPoint = "/home/sadbeast/workspace";
        proto = "virtiofs";
      }
      {
        tag = "ssh-host-keys";
        source = "${workspace}/ssh-host-keys";
        mountPoint = "/etc/ssh/host-keys";
        proto = "virtiofs";
        readOnly = true;
      }
    ];

    volumes = [
      {
        image = "var.img";
        mountPoint = "/var";
        size = 8192;
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

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/host-keys/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  users.users.sadbeast = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = sshKeys.sadbeast;
  };

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
    users.sadbeast.imports = [
      ../users/sadbeast/home.nix
      ../users/features/dev.nix
    ];
  };

  system.stateVersion = "25.11";
}
