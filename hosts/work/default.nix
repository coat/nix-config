{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/wireless.nix
    ../common/optional/libvirt.nix
    ../common/optional/docker.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "work";

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  services = {
    logind.extraConfig = ''
      HandleLidSwitchExternalPower=ignore
    '';
    tmate-ssh-server.enable = true;
  };

  virtualisation.vmware.guest.enable = true;

  users.users.sadbeast = {
    hashedPasswordFile = config.sops.secrets.sadbeast-password.path;

    extraGroups = ["docker" "libvirtd"];

    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  environment = {
    systemPackages = [
      # (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      #   qemu-system-x86_64 \
      #     -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
      #     "$@"
      # '')
      pkgs.qemu
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
