{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "joshua";

  # Pin mDNS to the LAN NIC so avahi doesn't announce on docker/veth/zerotier
  # interfaces and rename itself away from joshua.local via false collisions.
  services.avahi.allowInterfaces = ["enp0s31f6"];

  system.stateVersion = "24.11";

  users.groups.libvirtd.members = ["sadbeast"];
}
