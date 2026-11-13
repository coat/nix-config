{
  inputs,
  homeManagerSharedModules,
  outputs,
  lib,
  pkgs,
  ...
}: let
  microvmBase = import ./microvm-base.nix;

  vmDir = ../microvms;
  vmFiles = builtins.readDir vmDir;
  vmNames =
    map (n: lib.removeSuffix ".nix" n)
    (builtins.filter (n: lib.hasSuffix ".nix" n) (builtins.attrNames vmFiles));

  vmCfgs = lib.genAttrs vmNames (name: import (vmDir + "/${name}.nix"));

  # Host side of the guest bridge; guests take 192.168.83.2+ (microvms/*.nix).
  bridgeAddress = "192.168.83.1";

  vmIp = cfg: lib.head (lib.splitString "/" cfg.ipAddress);

  mkVm = name: let
    cfg = vmCfgs.${name};
  in {
    inherit name;
    value = {
      autostart = false;
      config = {
        imports = [
          inputs.microvm.nixosModules.microvm
          (microvmBase (cfg
            // {
              hostName = name;
              gateway = bridgeAddress;
              inherit inputs outputs homeManagerSharedModules;
            }))
        ];
      };
    };
  };

  # The microvm host module's tmpfiles rule for share sources never applies
  # here: a root-owned dir under /home/<user> is an "unsafe path transition"
  # that systemd-tmpfiles refuses. Create the workspace (and its parent) as
  # uid 1000 before virtiofsd starts, so the guest can write through virtiofs
  # and the VM runs on any host that imports this module without manual prep.
  prepWorkspace = pkgs.writeShellScript "microvm-prep-workspace" ''
    set -eu
    case "$1" in
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: cfg: ''
      ${name}) ws=${lib.escapeShellArg cfg.workspace} ;;'')
    vmCfgs)}
    *) exit 0 ;;
    esac
    mkdir -p "$ws"
    chown 1000:100 "$(dirname "$ws")" "$ws"
  '';

  # Host-side listeners forwarding to a guest, so a peer only needs to reach
  # the host (LAN or zerotier): sshProxyPort -> the guest's sshd, and
  # dashboardProxyPort -> its ai-beacon (e.g. modules/pair-beacon.nix).
  proxies = lib.concatLists (lib.mapAttrsToList (name: cfg:
    lib.optional (cfg ? sshProxyPort) {
      unit = "microvm-ssh-proxy-${name}";
      description = "SSH proxy to microvm '${name}'";
      port = cfg.sshProxyPort;
      target = "${vmIp cfg}:22";
    }
    ++ lib.optional (cfg ? dashboardProxyPort) {
      unit = "microvm-dashboard-proxy-${name}";
      description = "ai-beacon dashboard proxy to microvm '${name}'";
      port = cfg.dashboardProxyPort;
      target = "${vmIp cfg}:8090";
    })
  vmCfgs);

  proxyUnits = f: lib.listToAttrs (map (p: lib.nameValuePair p.unit (f p)) proxies);
in {
  systemd.network.netdevs."20-microbr".netdevConfig = {
    Kind = "bridge";
    Name = "microbr";
  };

  systemd.network.networks."20-microbr" = {
    matchConfig.Name = "microbr";
    addresses = [{Address = "${bridgeAddress}/24";}];
    networkConfig = {
      ConfigureWithoutCarrier = true;
    };
  };

  systemd.network.networks."21-microvm-tap" = {
    matchConfig.Name = "microvm*";
    networkConfig.Bridge = "microbr";
  };

  networking.nat = {
    enable = true;
    internalInterfaces = ["microbr"];
  };

  microvm.vms = builtins.listToAttrs (map mkVm vmNames);

  systemd.sockets = proxyUnits (p: {
    inherit (p) description;
    wantedBy = ["sockets.target"];
    listenStreams = [(toString p.port)];
  });

  systemd.services =
    {
      # virtiofsd is Required/Before microvm@, so the dir must exist here.
      "microvm-virtiofsd@".serviceConfig.ExecStartPre = ["+${prepWorkspace} %i"];
    }
    // proxyUnits (p: {
      serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${p.target}";
    });

  networking.firewall.allowedTCPPorts = map (p: p.port) proxies;
}
