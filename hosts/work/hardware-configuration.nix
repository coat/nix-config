{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ac2bd64-7a06-4972-af6e-beffa6567ba7";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  boot.initrd.luks.devices."work".device = "/dev/disk/by-uuid/7ce450be-7739-476e-9a8d-e25e57d8707f";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/0ac2bd64-7a06-4972-af6e-beffa6567ba7";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/0ac2bd64-7a06-4972-af6e-beffa6567ba7";
    fsType = "btrfs";
    options = ["subvol=persistent"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A468-9833";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [
    {device = "/dev/disk/by-label/swap";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    useDHCP = lib.mkDefault true;
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
  };
}
