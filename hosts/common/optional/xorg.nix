{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      windowManager.awesome = {
        enable = true;
        luaModules = with pkgs.luaPackages; [
          luarocks # is the package manager for Lua modules
          luadbi-mysql # Database abstraction layer
        ];
      };
      xkb.options = "ctrl:swapcaps";
    };
  };
}
