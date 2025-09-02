{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
      };

      "falken" = {
        user = "sadbeast";
        hostname = "sadbeast.com";
        port = 6973;
      };

      "crystalpalace" = {
        user = "sadbeast";
        hostname = "192.168.0.2";
        port = 6973;
      };

      "joshua" = {
        user = "sadbeast";
        hostname = "192.168.0.3";
      };

      "teamdraft" = {
        user = "sadbeast";
        hostname = "teamdraft.net";
        port = 6973;
      };

      "work" = {
        user = "kent";
        hostname = "192.168.0.26";
        forwardX11 = true;
        forwardX11Trusted = true;
      };
    };
  };
}
