{
  imports = [./desktop-base.nix];

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
