{...}: {
  imports = [
    ./global.nix
    ./desktop.nix
    ./wireguard.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.auto-optimise-store = false;

  programs.sway.enable = true;
}
