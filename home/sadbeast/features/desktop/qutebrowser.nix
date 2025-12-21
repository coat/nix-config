{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.qutebrowser = {
    enable = true;
    settings = {
      fonts = {
        default_family = "Iosevka";
        default_size = "10pt";
      };
    };
  };
}
