{
  imports = [
    ./hardware-configuration.nix
    ../../users/sadbeast/nixos.nix
    ../../modules/desktop-host.nix
  ];

  networking.hostName = "wopr";

  networking.firewall.allowedTCPPorts = [3000];

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "24.11";

  users.groups.libvirtd.members = ["sadbeast"];
}
