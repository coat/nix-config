{pkgs, ...}: {
  programs.qutebrowser = {
    package =
      if pkgs.stdenv.isDarwin
      then null
      else pkgs.qutebrowser;
    enable = true;
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
  };
}
