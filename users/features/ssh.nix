{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

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
    };
  };
}
