{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../users/sadbeast/nixos.nix
    ../../modules/desktop-host.nix
    ../../modules/wireless.nix
  ];

  networking.hostName = "wopr";

  services.logind.settings.Login.HandleLidSwitchExternalPower = "ignore";

  system.stateVersion = "24.11";
}
