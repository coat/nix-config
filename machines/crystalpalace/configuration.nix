{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixarr.nixosModules.default
    ../../modules/global.nix
    ../../modules/nixarr.nix
    ../../modules/dispatcharr.nix
    ../../modules/romm.nix
    ../../modules/samba.nix
    ../../modules/immich.nix
    ../../users/sadbeast/nixos.nix
  ];

  boot.loader.systemd-boot.configurationLimit = 3;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [3000 8080];
  };

  fileSystems."/mnt/files" = {
    device = "/dev/disk/by-uuid/98be24fc-82f9-455f-a7c2-afbea9ff67fb";
    fsType = "ext4";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
    ];
  };

  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};
}
