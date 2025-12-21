{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../users/sadbeast/nixos.nix
    ../../modules/desktop-host.nix
  ];

  networking.hostName = "joshua";

  system.stateVersion = "24.11";
}
