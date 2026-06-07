{
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "5";
      };
    };

    # storageDriver = "btrfs";
  };
}
