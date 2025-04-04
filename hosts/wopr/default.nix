{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/games.nix
    ../common/optional/docker.nix
    ../common/optional/libvirt.nix
    ../common/optional/wireless.nix
    ../common/optional/xorg.nix
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    SDL2
    libudev-zero
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "wopr";

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  services = {
    logind.extraConfig = ''
      HandleLidSwitchExternalPower=ignore
    '';
  };

  users.users.sadbeast = {
    extraGroups = ["docker"];

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
