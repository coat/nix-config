{...}: {
  imports = [
    ./global.nix
    ./desktop.nix
    ./wireguard-desktop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.auto-optimise-store = false;

  programs.sway.enable = true;
}
