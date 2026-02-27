{
  pkgs,
  lib,
  ...
}: {
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.isDarwin
      then null
      else pkgs.ghostty;
    enableZshIntegration = true;
    installVimSyntax = lib.mkForce (!pkgs.stdenv.isDarwin);
    settings = {
      window-decoration = false;
      resize-overlay = "never";
    };
  };
}
