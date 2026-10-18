{lib, ...}: {
  imports = [
    ../../users/kent.smith/desktop-home.nix
  ];

  home.stateVersion = lib.mkForce "25.11";
}
