{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        forwardAgent = true;
      };

      "cheyenne" = {
        user = "sadbeast";
        hostname = "cheyenne.sadbeast.com";
      };

      "crystalpalace" = {
        user = "sadbeast";
        hostname = "crystalpalace.local";
      };

      "joshua" = {
        user = "sadbeast";
        hostname = "joshua.local";
      };

      "wopr" = {
        user = "sadbeast";
        hostname = "wopr.local";
      };

      # Through the host-side proxy from microvms/pairvm.nix (sshProxyPort);
      # works from joshua itself as well as from any other LAN host.
      "pairvm" = {
        user = "pair";
        hostname = "joshua.local";
        port = 2222;
      };
    };
  };
}
