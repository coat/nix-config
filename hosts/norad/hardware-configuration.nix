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

  boot.initrd.availableKernelModules = ["ehci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/088d061d-7a81-4a91-9d97-c5958d5d4b6c";

  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  #boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
  #  mkdir -p /mnt

  #  # We first mount the btrfs root to /mnt
  #  # so we can manipulate btrfs subvolumes.
  #  mount -o subvol=/ /dev/mapper/enc /mnt

  #  # While we're tempted to just delete /root and create
  #  # a new snapshot from /root-blank, /root is already
  #  # populated at this point with a number of subvolumes,
  #  # which makes `btrfs subvolume delete` fail.
  #  # So, we remove them first.
  #  #
  #  # /root contains subvolumes:
  #  # - /root/var/lib/portables
  #  # - /root/var/lib/machines
  #  #
  #  # I suspect these are related to systemd-nspawn, but
  #  # since I don't use it I'm not 100% sure.
  #  # Anyhow, deleting these subvolumes hasn't resulted
  #  # in any issues so far, except for fairly
  #  # benign-looking errors from systemd-tmpfiles.
  #  btrfs subvolume list -o /mnt/root |
  #  cut -f9 -d' ' |
  #  while read subvolume; do
  #    echo "deleting /$subvolume subvolume..."
  #    btrfs subvolume delete "/mnt/$subvolume"
  #  done &&
  #  echo "deleting /root subvolume..." &&
  #  btrfs subvolume delete /mnt/root

  #  echo "restoring blank /root subvolume..."
  #  btrfs subvolume snapshot /mnt/root-blank /mnt/root

  #  # Once we're done rolling back to a blank snapshot,
  #  # we can unmount /mnt and continue on the boot process.
  #  umount /mnt
  #'';

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2990-A0D7";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8bcaf4f2-c648-420d-8605-72407206244c";

    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/8bcaf4f2-c648-420d-8605-72407206244c";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/8bcaf4f2-c648-420d-8605-72407206244c";
    fsType = "btrfs";
    neededForBoot = true;
    options = ["subvol=persistent" "compress=zstd" "noatime"];
  };

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
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
