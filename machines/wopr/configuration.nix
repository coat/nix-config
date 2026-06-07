{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "wopr";

  # Pin mDNS to the LAN NIC so avahi doesn't announce on docker/veth/zerotier
  # interfaces and rename itself away from wopr.local via false collisions.
  services.avahi.interfaces = ["wlp3s0"];

  networking.firewall.allowedTCPPorts = [3000];

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "24.11";

  users.groups.libvirtd.members = ["sadbeast"];
}
