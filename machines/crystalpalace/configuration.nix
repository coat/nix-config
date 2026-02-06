{inputs, ...}: {
  imports = [
    inputs.nixarr.nixosModules.default
    ../../modules/global.nix
    ../../modules/nixarr.nix
    ../../modules/docker.nix
    ../../modules/samba.nix
    ../../users/sadbeast/nixos.nix
  ];

  boot.loader.systemd-boot.configurationLimit = 3;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8080];
  };

  fileSystems."/mnt/files" = {
    device = "/dev/disk/by-uuid/98be24fc-82f9-455f-a7c2-afbea9ff67fb";
    fsType = "ext4";
  };
}
