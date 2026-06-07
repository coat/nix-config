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
    };
  };
}
