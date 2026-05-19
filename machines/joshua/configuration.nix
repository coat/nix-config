{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "joshua";

  system.stateVersion = "24.11";

  users.groups.libvirtd.members = ["sadbeast"];
}
