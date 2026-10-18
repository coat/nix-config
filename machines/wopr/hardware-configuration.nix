{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/b5b16d3a-54e0-4257-8529-ee0235674172";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/320B-DC40";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f86695d-facd-464a-83b9-79e3de93eeb6";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  # Not a typo: wopr's live home dir is /sadbeast at the top of the root
  # subvolume, so /home is the root subvolume mounted a second time. An older
  # copy lives at <root>/home/sadbeast. Migrate the data before changing this.
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7f86695d-facd-464a-83b9-79e3de93eeb6";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/7f86695d-facd-464a-83b9-79e3de93eeb6";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/7f86695d-facd-464a-83b9-79e3de93eeb6";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["subvol=persistent" "compress=zstd" "noatime"];
  };

  networking.interfaces.wlp3s0.useDHCP = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      input = {
        General = {
          UserspaceHID = true;
        };
      };
      settings = {
        General = {
          Experimental = true; # Show battery charge of Bluetooth devices
        };
      };
    };
    steam-hardware.enable = true;
  };
}
