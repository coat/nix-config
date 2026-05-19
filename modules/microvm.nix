{
  inputs,
  homeManagerSharedModules,
  outputs,
  lib,
  ...
}: let
  microvmBase = import ./microvm-base.nix;

  vmDir = ../microvms;
  vmFiles = builtins.readDir vmDir;
  vmNames =
    map (n: lib.removeSuffix ".nix" n)
    (builtins.filter (n: lib.hasSuffix ".nix" n) (builtins.attrNames vmFiles));

  mkVm = name: let
    cfg = import (vmDir + "/${name}.nix");
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
}
