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

  # VMs that set sshProxyPort get a host-side listener forwarding to the
  # guest's sshd, so a peer only needs to reach the host (LAN or zerotier).
  proxied = lib.filterAttrs (_: cfg: cfg ? sshProxyPort) vmCfgs;
in {
  systemd.network.netdevs."20-microbr".netdevConfig = {
    Kind = "bridge";
    Name = "microbr";
  };

  systemd.network.networks."20-microbr" = {
    matchConfig.Name = "microbr";
    addresses = [{Address = "192.168.83.1/24";}];
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

  systemd.sockets = lib.mapAttrs' (name: cfg:
    lib.nameValuePair "microvm-ssh-proxy-${name}" {
      description = "SSH proxy to microvm '${name}'";
      wantedBy = ["sockets.target"];
      listenStreams = [(toString cfg.sshProxyPort)];
    })
  proxied;

  systemd.services =
    {
      # virtiofsd is Required/Before microvm@, so the dir must exist here.
      "microvm-virtiofsd@".serviceConfig.ExecStartPre = ["+${prepWorkspace} %i"];
    }
    // lib.mapAttrs' (name: cfg:
      lib.nameValuePair "microvm-ssh-proxy-${name}" {
        serviceConfig.ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${vmIp cfg}:22";
      })
    proxied;

  networking.firewall.allowedTCPPorts = lib.mapAttrsToList (_: cfg: cfg.sshProxyPort) proxied;
}
