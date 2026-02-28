{
  inputs,
  homeManagerSharedModules,
  outputs,
  ...
}: let
  microvmBase = import ./microvm-base.nix;
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

  microvm.vms.devvm = {
    autostart = false;
    config = {
      imports = [
        inputs.microvm.nixosModules.microvm
        (microvmBase {
          hostName = "devvm";
          ipAddress = "192.168.83.2/24";
          tapId = "microvm0";
          mac = "02:00:00:00:00:01";
          workspace = "/home/sadbeast/microvm/dev";
          inherit inputs outputs homeManagerSharedModules;
        })
      ];
    };
  };
}
