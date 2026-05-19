{pkgs, ...}: {
  imports = [
    ../../modules/global.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "falken";

  services.xserver = {
    enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        awesome-wm-widgets # Community collection of widgets
      ];
    };
  };

  virtualisation.vmware.guest.enable = true;

  environment.systemPackages = with pkgs; [open-vm-tools];
}
