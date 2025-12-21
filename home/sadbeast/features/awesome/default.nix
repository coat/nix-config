{
  config,
  lib,
  pkgs,
  ...
}: {
  xdg.configFile."awesome" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix-config/home/sadbeast/features/awesome/config";
    force = true;
  };
  home = {
    sessionVariables = {
      XKBOPTIONS = "ctrl:swapcaps";
    };
  };
}
