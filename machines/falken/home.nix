{lib, ...}: {
  imports = [
    ../../users/kent/desktop-home.nix
  ];

  home.stateVersion = lib.mkForce "25.11";
}
