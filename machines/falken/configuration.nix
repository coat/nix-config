{pkgs, ...}: {
  imports = [
    ../../modules/global.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "falken";

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.defaultSession = "none+i3";

  virtualisation.vmware.guest.enable = true;

  environment.systemPackages = with pkgs; [open-vm-tools];
}
