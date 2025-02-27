{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/wireless.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "norad";

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  services = {
    logind.extraConfig = ''
      HandleLidSwitchExternalPower=ignore
    '';

    blueman.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
