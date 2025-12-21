{...}: {
  imports = [
    ./hardware-configuration.nix

    ../../users/sadbeast/nixos.nix
    ../../modules/global.nix
    ../../modules/desktop.nix

    ../../modules/wireguard.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "joshua";

  # Slows down write operations considerably
  nix.settings.auto-optimise-store = false;

  programs.sway.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
