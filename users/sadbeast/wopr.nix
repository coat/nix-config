{
  imports = [
    ./desktop-base.nix
    ../features/desktop/games.nix
  ];

  programs.bluetuith.enable = true;

  services.syncthing.settings = {
    folders = {
      "vault" = {
        path = "/home/sadbeast/docs/vault";
        devices = ["android"];
      };
    };
  };
}
